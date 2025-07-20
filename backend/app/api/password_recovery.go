package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/api_email"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

var recovery_users = make(map[string]string)

// @Summary      Запрос на сброс пароля
// @Description  Отправляет код подтверждения на email пользователя для восстановления пароля
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request  body      Email_struct    true  "Email пользователя"
// @Success      200     {object}  Success_answer  "Код подтверждения отправлен"
// @Failure      400     {object}  Error_answer    "Невалидный запрос или пользователь не найден"
// @Failure      405     {object}  Error_answer    "Метод не разрешен"
// @Router       /forgot_password [post]
func PasswordRecovery_ForgotPassword(w http.ResponseWriter, r *http.Request) {
	// Log password recovery attempt
	log.Println("Request to recovery password!")

	// Set response content type to JSON
	w.Header().Set("Content-Type", "application/json")

	var request Email_struct

	// Verify request method is POST
	if r.Method != http.MethodPost {
		// Return error if method is not POST
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	// Decode JSON request body
	err := json.NewDecoder(r.Body).Decode(&request)
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

	// Check if user exists in database
	err = database.CheckUser(request.Email, db)
	if err != database.ErrDuplicateUser {
		// Handle case when user doesn't exist or other DB error occurs
		log.Println("User not found or other errors")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "User not found or other errors",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Generate 5-digit verification code
	email_code, err := Generate5DigitCode()

	// Store user email and code in temporary map
	recovery_users[request.Email] = email_code

	// Send email with verification code (with 3 retry attempts)
	api_email.EmailQueue <- api_email.EmailTask{
		To:      request.Email,
		Subject: "Email Validation",
		Body:    email_code,
		Retries: 3,
	}

	// Return success response
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Success_answer{
		Status: "OK",
		Code:   http.StatusOK,
	})
}

// @Summary      Проверка кода подтверждения
// @Description  Валидирует код для сброса пароля, отправленный на email
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request  body      Code_verification  true  "Email и код подтверждения"
// @Success      200     {object}  Success_answer      "Код подтвержден"
// @Failure      400     {object}  Error_answer        "Неверный код или пользователь не найден"
// @Failure      405     {object}  Error_answer        "Метод не разрешен"
// @Router       /commit_code_reset_password [post]
func PasswordRecovery_CommitCode(w http.ResponseWriter, r *http.Request) {
	// Log code verification attempt
	log.Println("Request to recovery password!")

	// Set response content type to JSON
	w.Header().Set("Content-Type", "application/json")

	var request Code_verification

	// Verify request method is POST
	if r.Method != http.MethodPost {
		// Return error if method is not POST
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	// Decode JSON request body
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		// Handle JSON decoding error
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid JSON",
			Code:  http.StatusBadRequest,
		})
	}

	// Lookup user's verification code
	code := recovery_users[request.Email]
	if code == "" {
		// Handle case when user not found in recovery process
		log.Println("User not found")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "User not found",
			Code:  http.StatusBadGateway,
		})
	}

	// Verify the provided code matches stored code
	if code != request.Code {
		// Handle incorrect verification code
		log.Println("Code is incorrect")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Code is incorrect",
			Code:  http.StatusBadGateway,
		})
	}
	// Return success response if code matches
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	})
}

// @Summary      Установка нового пароля
// @Description  Устанавливает новый пароль после успешной проверки кода подтверждения
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request  body      Update_password  true  "Email и новый пароль"
// @Success      200     {object}  Success_answer   "Пароль успешно изменен"
// @Failure      400     {object}  Error_answer     "Невалидный запрос или ошибка обновления пароля"
// @Failure      405     {object}  Error_answer     "Метод не разрешен"
// @Router       /reset_password [post]
func PasswordRecovery_ResetPassword(w http.ResponseWriter, r *http.Request) {
	// Log password reset attempt
	log.Println("Request to recovery password!")

	// Set response content type to JSON
	w.Header().Set("Content-Type", "application/json")

	var request Update_password

	// Verify request method is POST
	if r.Method != http.MethodPost {
		// Return error if method is not POST
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	// Decode JSON request body
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		// Handle JSON decoding error
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid JSON",
			Code:  http.StatusBadRequest,
		})
	}

	// Verify user is in recovery process
	code := recovery_users[request.Email]
	if code == "" {
		// Handle case when user not found in recovery process
		log.Println("User not found")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "User not found",
			Code:  http.StatusBadRequest,
		})
	}

	// Update user's password in database
	err = database.UpdateUsersPassword(request.Email, request.NewPassword, db)
	if err != nil {
		// Handle password update failure
		log.Println("Cannot update password")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Cannot update password",
			Code:  http.StatusBadRequest,
		})
	}

	// Remove used verification code from temporary storage
	delete(recovery_users, request.Email)

	// Return success response
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	})
}
