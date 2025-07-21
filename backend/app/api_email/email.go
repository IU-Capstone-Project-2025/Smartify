package api_email

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log"
	"net/smtp"
	"os"
	"sync"
	"time"
)

var db *sql.DB
var temporary_users = make(map[string]string)
var EmailQueue chan EmailTask
var wg sync.WaitGroup

type EmailTask struct {
	To      string
	Subject string
	Body    string
	Retries int
}

func InitEmailApi(db_ *sql.DB) {
	db = db_
	EmailQueue = make(chan EmailTask, 100)
	go processEmailQueue()
}

func processEmailQueue() {
	for task := range EmailQueue {
		wg.Add(1)
		go func(t EmailTask) {
			defer wg.Done()
			err := sendEmailWithRetry(t.To, t.Subject, t.Body, t.Retries)
			if err != nil {
				log.Printf("Failed to send email to %s after %d retries: %v", t.To, t.Retries, err)
			}
		}(task)
	}
}

func sendEmailWithRetry(to, subject, body string, maxRetries int) error {
	var err error
	for i := 0; i <= maxRetries; i++ {
		if i > 0 {
			time.Sleep(time.Duration(i*i) * time.Second)
		}
		err = sendEmail(to, subject, body)
		if err == nil {
			return nil
		}
		log.Printf("Attempt %d to send email to %s failed: %v", i+1, to, err)
	}
	return fmt.Errorf("after %d attempts: %w", maxRetries, err)
}

func sendEmail(to, subject, body string) error {
	smtpHost := os.Getenv("SMTP_HOST")
	smtpPort := os.Getenv("SMTP_PORT")
	smtpUsername := os.Getenv("SMTP_USERNAME")
	smtpPassword := os.Getenv("SMTP_PASSWORD")

	// Формируем письмо
	msg := []byte(
		"To: " + to + "\r\n" +
			"Subject: " + subject + "\r\n" +
			"\r\n" +
			body + "\r\n",
	)

	// Аутентификация и отправка с таймаутом
	var auth smtp.Auth
	if smtpUsername != "" && smtpPassword != "" {
		auth = smtp.PlainAuth("", smtpUsername, smtpPassword, smtpHost)
	} else {
		auth = nil
	}

	// Создаем контекст с таймаутом
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Канал для получения результата
	done := make(chan error, 1)

	go func() {
		done <- smtp.SendMail(
			smtpHost+":"+smtpPort,
			auth,
			smtpUsername,
			[]string{to},
			msg,
		)
	}()

	select {
	case <-ctx.Done():
		return errors.New("SMTP operation timed out")
	case err := <-done:
		return err
	}
}
