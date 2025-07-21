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

// Global variables for email service
var db *sql.DB
var temporary_users = make(map[string]string)
var EmailQueue chan EmailTask // Channel for email tasks
var wg sync.WaitGroup         // WaitGroup for tracking email goroutines

// EmailTask represents an email sending task
type EmailTask struct {
	To      string // Recipient email address
	Subject string // Email subject
	Body    string // Email body content
	Retries int    // Maximum retry attempts
}

// InitEmailApi initializes the email service with database connection
func InitEmailApi(db_ *sql.DB) {
	db = db_
	// Initialize buffered email queue channel
	EmailQueue = make(chan EmailTask, 100)
	// Start email queue processor
	go processEmailQueue()
}

// processEmailQueue continuously processes email tasks from the queue
func processEmailQueue() {
	for task := range EmailQueue {
		wg.Add(1)
		go func(t EmailTask) {
			defer wg.Done()
			// Attempt to send email with retries
			err := sendEmailWithRetry(t.To, t.Subject, t.Body, t.Retries)
			if err != nil {
				log.Printf("Failed to send email to %s after %d retries: %v", t.To, t.Retries, err)
			}
		}(task)
	}
}

// sendEmailWithRetry attempts to send an email with exponential backoff retries
func sendEmailWithRetry(to, subject, body string, maxRetries int) error {
	var err error
	for i := 0; i <= maxRetries; i++ {
		if i > 0 {
			// Exponential backoff: wait i^2 seconds before retry
			time.Sleep(time.Duration(i*i) * time.Second)
		}
		err = sendEmail(to, subject, body)
		if err == nil {
			return nil // Success
		}
		log.Printf("Attempt %d to send email to %s failed: %v", i+1, to, err)
	}
	return fmt.Errorf("after %d attempts: %w", maxRetries, err)
}

// sendEmail sends a single email with timeout handling
func sendEmail(to, subject, body string) error {
	// Get SMTP configuration from GitHub Secrets
	smtpHost := os.Getenv("SMTP_HOST")
	smtpPort := os.Getenv("SMTP_PORT")
	smtpUsername := os.Getenv("SMTP_USERNAME")
	smtpPassword := os.Getenv("SMTP_PASSWORD")

	// Compose email message
	msg := []byte(
		"To: " + to + "\r\n" +
			"Subject: " + subject + "\r\n" +
			"\r\n" +
			body + "\r\n",
	)

	// Set up SMTP authentication if credentials are provided
	var auth smtp.Auth
	if smtpUsername != "" && smtpPassword != "" {
		auth = smtp.PlainAuth("", smtpUsername, smtpPassword, smtpHost)
	} else {
		auth = nil
	}

	// Create context with 30 second timeout
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Channel for receiving send result
	done := make(chan error, 1)

	// Goroutine to handle SMTP send operation
	go func() {
		done <- smtp.SendMail(
			smtpHost+":"+smtpPort,
			auth,
			smtpUsername,
			[]string{to},
			msg,
		)
	}()

	// Wait for send operation to complete or timeout
	select {
	case <-ctx.Done():
		return errors.New("SMTP operation timed out")
	case err := <-done:
		return err
	}
}
