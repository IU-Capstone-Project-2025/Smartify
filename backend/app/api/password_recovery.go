package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/api_email"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

// const DOMAIN = "localhost"
// const PORT = "22025"

var recovery_users = make(map[string]string)

// @Summary      Запрос на сброс пароля
// @Description  Отправляет код подтверждения на email
// @Tags         auth
// @Accept       json
// @Produce      json
// @Router       /forgot_password [post]
func PasswordRecovery_ForgotPassword(w http.ResponseWriter, r *http.Request) {
	log.Println("Request to recovery password!")
	w.Header().Set("Content-Type", "application/json")

	var request struct {
		Email string `json:"email"`
	}

	// Расшифровываем сообщение
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid JSON",
		})
		return
	}

	// Проверка на существование пользователя в базе данных
	err = database.CheckUser(request.Email, db)
	if err != database.ErrDuplicateUser {
		log.Println("User not found or other errors")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "User not found or other errors",
		})
		return
	}

	// --------------------ВВЕРСИЯ С УНИКАЛЬНОЙ ССЫЛКОЙ------------------------------
	// Генерируем токен
	// token := uuid.New().String()
	// Создаем ссылку для востановления пароля
	// resetLink := "http://" + DOMAIN + ":" + PORT + "/reset_password_page?token=" + token
	// Добавляем токен и почту в список пользователей на восстановление
	//recovery_users[token] = request.Email
	// ------------------------------------------------------------------------------

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
	json.NewEncoder(w).Encode(map[string]string{"code": "OK"})
}

// @Summary      Установка нового пароля
// @Description  Меняет пароль после подтверждения кода
// @Tags         auth
// @Accept       json
// @Produce      json
// @Router       /reset_password [post]
func PasswordRecovery_CommitCode(w http.ResponseWriter, r *http.Request) {
	log.Println("Request to recovery password!")
	w.Header().Set("Content-Type", "application/json")

	var request struct {
		Email string `json:"email"`
		Code  string `json:"code"`
	}

	// Расшифровываем сообщение
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid JSON",
		})
	}

	// Ищем пользователя по почте
	code := recovery_users[request.Email]
	if code == "" {
		log.Println("User not found")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "User not found",
		})
	}

	// Проверяем код
	if code != request.Code {
		log.Println("Code is incorrect")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Code is incorrect",
		})
	}
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"type": "OK",
	})
}

// @Summary      Подтверждение кода для сброса пароля
// @Description  Проверяет код и разрешает смену пароля
// @Tags         auth
// @Accept       json
// @Produce      json
func PasswordRecovery_ResetPassword(w http.ResponseWriter, r *http.Request) {
	log.Println("Request to recovery password!")
	w.Header().Set("Content-Type", "application/json")

	var request struct {
		Email       string `json:"email"`
		NewPassword string `json:"newPassword"`
	}

	// Расшифровываем сообщение
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid JSON",
		})
	}

	// Ищем пользователя по токену
	code := recovery_users[request.Email]
	if code == "" {
		log.Println("User not found")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "User not found",
		})
	}

	// Обновляем пароль в базе данных
	err = database.UpdateUsersPassword(request.Email, request.NewPassword, db)
	if err != nil {
		log.Println("Cannot update password")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Cannot update password",
		})
	}

	// Удаляем использованный код
	delete(recovery_users, request.Email)
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"type": "OK",
	})
}
