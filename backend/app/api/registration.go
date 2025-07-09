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
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
)

var db *sql.DB
var temporary_users = make(map[string]string)

func InitDatabase(db_ *sql.DB) {
	db = db_
}

// Для первого этапа регистрации (Ввод почты и подтверждение)
func RegistrationHandler_EmailValidation(w http.ResponseWriter, r *http.Request) {
	log.Println("Registration:")
	w.Header().Set("Content-Type", "application/json")

	var email struct {
		Email string `json:"email"`
	}

	// Try to decode message
	err := json.NewDecoder(r.Body).Decode(&email)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid request",
		})
		return
	}

	// Print Message
	log.Printf("User: %s", email.Email)

	// Check if the mail is valid
	if !database.IsValidEmail(email.Email) {
		log.Printf("Not valid Email")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Not valid Email",
		})
		return
	}

	// Check if the mail was used
	if err := database.CheckUser(email.Email, db); err != nil {
		log.Printf("User already exists")
		w.WriteHeader(http.StatusConflict)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "User already exists",
		})
		return
	}

	// Generate number
	number, err := Generate5DigitCode()
	if err != nil {
		log.Printf("Cannot generate code: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Cannot generate code",
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
	json.NewEncoder(w).Encode(map[string]interface{}{
		"code": http.StatusOK,
	})
}

// Для второго этапа регистрации (Подтверждение кода)
func RegistrationHandler_CodeValidation(w http.ResponseWriter, r *http.Request) {
	log.Println("Registration-CodeValidation:")
	w.Header().Set("Content-Type", "application/json")

	type request struct {
		Email string `json:"email"`
		Code  string `json:"code"`
	}
	var user request

	// Декодируем json сообщение
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid JSON",
		})
		return
	}

	// Проверяем сущетсвоание пользователя
	if _, exists := temporary_users[user.Email]; !exists {
		log.Printf("User does not exists")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "User does not exists...",
		})
		return
	}

	// Проверяем код
	if user.Code != temporary_users[user.Email] {
		log.Printf("Code does not equal")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Code does not equal...",
		})
		return
	}

	// Отправляем успешный ответ
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"code": http.StatusOK,
	})
}

// Для третьего этапа (Создание пароля)
func RegistrationHandler_Password(w http.ResponseWriter, r *http.Request) {
	log.Println("Registration-Password:")
	w.Header().Set("Content-Type", "application/json")

	type request struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	var user_request request

	// Декодируем json сообщение
	err := json.NewDecoder(r.Body).Decode(&user_request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid JSON",
		})
		return
	}

	// Проверяем сущетсвоание пользователя
	if _, exists := temporary_users[user_request.Email]; !exists {
		log.Printf("User does not exists")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "User does not exists...",
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
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Cannot create user... error with database",
		})
		return
	}
	delete(temporary_users, user_request.Email)

	// Находим пользовтеля в db, чтобы получить его id
	err = database.FindUserByEmail(user_request.Email, &user, db)
	if err != nil {
		log.Printf("Error with database")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Cannot create user... error with database",
		})
		return
	}

	// Генерируем accessToken и refreshToken
	accessToken, refreshToken, err := auth.GenerateTokens(user.ID)
	if err != nil {
		log.Printf("Cannot generate tokens: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Error generating tokens",
		})
		return
	}

	// Сохраняем refreshToken
	err = database.StoreRefreshToken(user.ID, refreshToken, db)
	if err != nil {
		log.Printf("Cannot store refresh token: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Error saving refresh token",
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
