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

// Map to store temporary users during registration with their verification codes
var temporary_users = make(map[string]string)

// Initialize database connection
func InitDatabase(db_ *sql.DB) {
	db = db_
}

// @Summary      Валидация email при регистрации
// @Description  Проверяет валидность email и отправляет код подтверждения. Email не должен быть уже зарегистрирован.
// @Tags         registration
// @Accept       json
// @Produce      json
// @Param        request  body      Email_struct    true  "Email пользователя"
// @Success      200     {object}  Success_answer  "Код подтверждения отправлен"
// @Failure      400     {object}  Error_answer    "Невалидный email или запрос"
// @Failure      409     {object}  Error_answer    "Пользователь уже существует"
// @Failure      500     {object}  Error_answer    "Ошибка сервера (генерация кода, отправка email)"
// @Router       /registration_emailvalidation [post]
func RegistrationHandler_EmailValidation(w http.ResponseWriter, r *http.Request) {
	// Log registration attempt
	log.Println("Registration:")

	// Set response content type to JSON
	w.Header().Set("Content-Type", "application/json")

	var email Email_struct

	// Decode JSON request body
	err := json.NewDecoder(r.Body).Decode(&email)
	if err != nil {
		// Handle JSON decoding error
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid request",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Log received email (for debugging)
	log.Printf("User: %s", email.Email)

	// Validate email format
	if !database.IsValidEmail(email.Email) {
		log.Printf("Not valid Email")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Not valid Email",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Check if email is already registered
	if err := database.CheckUser(email.Email, db); err != nil {
		log.Printf("User already exists")
		w.WriteHeader(http.StatusConflict)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "User already exists",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Generate 5-digit verification code
	number, err := Generate5DigitCode()
	if err != nil {
		log.Printf("Cannot generate code: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Cannot generate code",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Store email and code in temporary map
	temporary_users[email.Email] = number

	// Send verification code via email (with 3 retry attempts)
	api_email.EmailQueue <- api_email.EmailTask{
		To:      email.Email,
		Subject: "Email Validation",
		Body:    number,
		Retries: 3,
	}

	// Return success response
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	})
}

// @Summary      Проверка кода подтверждения
// @Description  Валидирует код, отправленный на email пользователя
// @Tags         registration
// @Accept       json
// @Produce      json
// @Param        request  body      Code_verification  true  "Email и код подтверждения"
// @Success      200     {object}  Success_answer      "Код подтвержден"
// @Failure      400     {object}  Error_answer        "Неверный код или пользователь не найден"
// @Failure      405     {object}  Error_answer        "Метод не разрешен"
// @Router       /registration_codevalidation [post]
func RegistrationHandler_CodeValidation(w http.ResponseWriter, r *http.Request) {
	// Log code validation attempt
	log.Println("Registration-CodeValidation:")

	// Set response content type to JSON
	w.Header().Set("Content-Type", "application/json")

	var user Code_verification

	// Decode JSON request body
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		// Handle JSON decoding error
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid JSON",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Check if user exists in temporary storage
	if _, exists := temporary_users[user.Email]; !exists {
		log.Printf("User does not exists")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "User does not exists...",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Verify the provided code matches stored code
	if user.Code != temporary_users[user.Email] {
		log.Printf("Code does not equal")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Code does not equal...",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Return success response if code matches
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	})
}

// @Summary      Завершение регистрации
// @Description  Сохраняет пароль пользователя и выдает токены доступа
// @Tags         registration
// @Accept       json
// @Produce      json
// @Param        request  body      User_email_password  true  "Email и пароль пользователя"
// @Success      200     {object}  Tokens_answer         "Токены доступа"
// @Failure      400     {object}  Error_answer          "Невалидные данные или пользователь не найден"
// @Failure      405     {object}  Error_answer          "Метод не разрешен"
// @Failure      500     {object}  Error_answer          "Ошибка сервера (БД, генерация токенов)"
// @Router       /registration_password [post]
func RegistrationHandler_Password(w http.ResponseWriter, r *http.Request) {
	// Log password registration attempt
	log.Println("Registration-Password:")

	// Set response content type to JSON
	w.Header().Set("Content-Type", "application/json")

	var user_request User_email_password

	// Decode JSON request body
	err := json.NewDecoder(r.Body).Decode(&user_request)
	if err != nil {
		// Handle JSON decoding error
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid JSON",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Verify user exists in temporary storage
	if _, exists := temporary_users[user_request.Email]; !exists {
		log.Printf("User does not exists")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "User does not exists...",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Prepare user data for database
	var user database.User
	user.Email = user_request.Email
	user.Password_hash = user_request.Password
	user.Created_at = time.Now().Format("2000-01-02 12:00")

	// Add new user to database
	err = database.Add_new_user(user, db)
	if err != nil {
		// Handle database error
		log.Printf("Error with database")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Cannot create user... error with database",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Remove user from temporary storage
	delete(temporary_users, user_request.Email)

	// Retrieve user from database to get assigned ID
	err = database.FindUserByEmail(user_request.Email, &user, db)
	if err != nil {
		log.Printf("Error with database")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Cannot create user... error with database",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Generate JWT tokens
	accessToken, refreshToken, err := auth.GenerateTokens(user.ID)
	if err != nil {
		// Handle token generation error
		log.Printf("Cannot generate tokens: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Error generating tokens",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Store refresh token in database
	err = database.StoreRefreshToken(user.ID, refreshToken, db)
	if err != nil {
		// Handle token storage error
		log.Printf("Cannot store refresh token: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Error saving refresh token",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Prepare token response
	resp := Tokens_answer{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}

	// Return tokens to client
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(resp)
}

// Generates a random 5-digit code (including leading zeros)
func Generate5DigitCode() (string, error) {
	max := big.NewInt(100000)
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return "", fmt.Errorf("Failed to generate random number: %v", err)
	}
	return fmt.Sprintf("%05d", n), nil
}
