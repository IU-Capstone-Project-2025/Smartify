package api

import (
	"crypto/rand"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"math/big"
	"net/http"
	"time"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/api_email"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

var db *sql.DB
var temporary_users = make(map[string]string)

func InitDatabase(db_ *sql.DB) {
	db = db_
}

// @Summary      Отправка email для регистрации
// @Description  Проверяет email и отправляет код подтверждения
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        credentials  body	email_struct  true  "Email и пароль"
// @Success		 200 {Object} success_answer
// @Failure		 409 {Object} error_answer
// @Failure		 400 {Object} error_answer
// @Failure		 500 {Object} error_answer
// @Router       /registration_emailvalidation [post]
func RegistrationHandler_EmailValidation(w http.ResponseWriter, r *http.Request) {
	log.Println("Registration:")
	w.Header().Set("Content-Type", "application/json")

	var email email_struct

	// Try to decode message
	err := json.NewDecoder(r.Body).Decode(&email)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Invalid request",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Print Message
	log.Printf("User: %s", email.Email)

	// Check if the mail is valid
	if !database.IsValidEmail(email.Email) {
		log.Printf("Not valid Email")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Not valid Email",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Check if the mail was used
	if err := database.CheckUser(email.Email, db); err != nil {
		log.Printf("User already exists")
		w.WriteHeader(http.StatusConflict)
		json.NewEncoder(w).Encode(error_answer{
			Error: "User already exists",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Generate number
	number, err := Generate5DigitCode()
	if err != nil {
		log.Printf("Cannot generate code: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Cannot generate code",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Add user in map
	temporary_users[email.Email] = number

	// Send number to email (3 attempts)
	api_email.EmailQueue <- api_email.EmailTask{
		To:      email.Email,
		Subject: "Email Validation",
		Body:    number,
		Retries: 3,
	}

	// Send successful answer
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	})
}

// @Summary      Проверка кода подтверждения
// @Description  Валидирует код, отправленный на email
// @Tags         auth
// @Param        credentials  body	code_verification  true  "Email и пароль"
// @Accept       json
// @Produce      json
// @Success		 200 {Object} tokens_answer
// @Failure		 405 {Object} error_answer
// @Failure		 400 {Object} error_answer
// @Router       /registration_codevalidation [post]
func RegistrationHandler_CodeValidation(w http.ResponseWriter, r *http.Request) {
	log.Println("Registration-CodeValidation:")
	w.Header().Set("Content-Type", "application/json")

	var user code_verification

	// Декодируем json сообщение
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Invalid JSON",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Проверяем сущетсвоание пользователя
	if _, exists := temporary_users[user.Email]; !exists {
		log.Printf("User does not exists")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(error_answer{
			Error: "User does not exists...",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Проверяем код
	if user.Code != temporary_users[user.Email] {
		log.Printf("Code does not equal")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Code does not equal...",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Отправляем успешный ответ
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	})
}

// @Summary      Установка пароля
// @Description  Завершает регистрацию, сохраняя пароль
// @Tags         auth
// @Accept       json
// @Produce      json
// @Success		 200 {Object} tokens_answer
// @Failure		 405 {Object} error_answer
// @Failure		 400 {Object} error_answer
// @Router       /registration_password [post]
func RegistrationHandler_Password(w http.ResponseWriter, r *http.Request) {
	log.Println("Registration-Password:")
	w.Header().Set("Content-Type", "application/json")

	var user_request user_email_password

	// Декодируем json сообщение
	err := json.NewDecoder(r.Body).Decode(&user_request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid JSON",
		})
		json.NewEncoder(w).Encode(error_answer{
			Error: "Code does not equal...",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Проверяем сущетсвоание пользователя
	if _, exists := temporary_users[user_request.Email]; !exists {
		log.Printf("User does not exists")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(error_answer{
			Error: "User does not exists...",
			Code:  http.StatusBadRequest,
		})
		return
	}

	var user database.User
	user.Email = user_request.Email
	user.Password_hash = user_request.Password
	user.Created_at = time.Now().Format("2000-01-02 12:00")

	// Добавляем пользователя в базу данных
	err = database.Add_new_user(user, db)
	if err != nil {
		log.Printf("Error with database")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Cannot create user... error with database",
			Code:  http.StatusBadRequest,
		})
		return
	}
	delete(temporary_users, user_request.Email)

	// Находим пользовтеля в db, чтобы получить его id
	err = database.FindUserByEmail(user_request.Email, &user, db)
	if err != nil {
		log.Printf("Error with database")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Cannot create user... error with database",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Генерируем accessToken и refreshToken
	accessToken, refreshToken, err := auth.GenerateTokens(user.ID)
	if err != nil {
		log.Printf("Cannot generate tokens: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Error generating tokens",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Сохраняем refreshToken
	err = database.StoreRefreshToken(user.ID, refreshToken, db)
	if err != nil {
		log.Printf("Cannot store refresh token: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Error saving refresh token",
			Code:  http.StatusBadRequest,
		})
		return
	}

	resp := map[string]string{
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	}

	// Send successful answer
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(resp)
}

// Функция для генерации 5-значного числа (с ведущими нулями в том числе)
func Generate5DigitCode() (string, error) {
	max := big.NewInt(100000)
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return "", fmt.Errorf("Failed to generate random number: %v", err)
	}
	return fmt.Sprintf("%05d", n), nil
}
