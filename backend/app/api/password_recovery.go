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
// @Description  Отправляет код подтверждения на email
// @Tags         password_recovery
// @Accept       json
// @Produce      json
// @Param        credentials  body  database.User  true  "Email и пароль"
// @Success		 200	{object}	Success_answer
// @Failure		 405	{object}	Error_answer
// @Failure		 400	{object}	Error_answer
// @Router       /forgot_password [post]
func PasswordRecovery_ForgotPassword(w http.ResponseWriter, r *http.Request) {
	log.Println("Request to recovery password!")
	w.Header().Set("Content-Type", "application/json")

	var request database.User

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	// Расшифровываем сообщение
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid JSON",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Проверка на существование пользователя в базе данных
	err = database.CheckUser(request.Email, db)
	if err != database.ErrDuplicateUser {
		log.Println("User not found or other errors")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "User not found or other errors",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Генерируем код
	email_code, err := Generate5DigitCode()

	// Добавляем пользователя в список
	recovery_users[request.Email] = email_code

	// Отправляем письмо (3 попытки)
	api_email.EmailQueue <- api_email.EmailTask{
		To:      request.Email,
		Subject: "Email Validation",
		Body:    email_code,
		Retries: 3,
	}

	// Ответ об успехе
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Success_answer{
		Status: "OK",
		Code:   http.StatusOK,
	})
}

// @Summary      Установка нового пароля
// @Description  Меняет пароль после подтверждения кода
// @Tags         password_recovery
// @Accept       json
// @Produce      json
// @Param        credentials  body  Code_verification  true  "Email и код"
// @Success		 200	{object}	Success_answer
// @Failure		 405	{object}	Error_answer
// @Failure		 400	{object}	Error_answer
// @Router       /commit_code_reset_password [post]
func PasswordRecovery_CommitCode(w http.ResponseWriter, r *http.Request) {
	log.Println("Request to recovery password!")
	w.Header().Set("Content-Type", "application/json")

	var request Code_verification

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	// Расшифровываем сообщение
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid JSON",
			Code:  http.StatusBadRequest,
		})
	}

	// Ищем пользователя по почте
	code := recovery_users[request.Email]
	if code == "" {
		log.Println("User not found")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "User not found",
			Code:  http.StatusBadGateway,
		})
	}

	// Проверяем код
	if code != request.Code {
		log.Println("Code is incorrect")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Code is incorrect",
			Code:  http.StatusBadGateway,
		})
	}
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	})
}

// @Summary      Подтверждение кода для сброса пароля
// @Description  Проверяет код и разрешает смену пароля
// @Tags         password_recovery
// @Accept       json
// @Produce      json
// @Param        credentials  body  Update_password  true  "Email и пароль"
// @Success		 200	{object}	Success_answer
// @Failure		 405	{object}	Error_answer
// @Failure		 400	{object}	Error_answer
// @Router       /reset_password [post]
func PasswordRecovery_ResetPassword(w http.ResponseWriter, r *http.Request) {
	log.Println("Request to recovery password!")
	w.Header().Set("Content-Type", "application/json")

	var request Update_password

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	// Расшифровываем сообщение
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid JSON",
			Code:  http.StatusBadRequest,
		})
	}

	// Ищем пользователя по токену
	code := recovery_users[request.Email]
	if code == "" {
		log.Println("User not found")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "User not found",
			Code:  http.StatusBadRequest,
		})
	}

	// Обновляем пароль в базе данных
	err = database.UpdateUsersPassword(request.Email, request.NewPassword, db)
	if err != nil {
		log.Println("Cannot update password")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Cannot update password",
			Code:  http.StatusBadRequest,
		})
	}

	// Удаляем использованный код
	delete(recovery_users, request.Email)
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	})
}
