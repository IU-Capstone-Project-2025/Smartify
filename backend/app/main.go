package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/api"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/api_email"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
	_ "github.com/IU-Capstone-Project-2025/Smartify/backend/app/docs"
	httpSwagger "github.com/swaggo/http-swagger"
)

// @title           Smartify Backend API
// @version         1.0
// @description     REST API для доступа внешним устройствам ко внутренней системе Smartify

// @contact.name   Smartify Working Mail
// @contact.email  projectsmartifyapp@gmail.com

// @host      localhost:8080
// @BasePath  /api

func main() {
	http.Handle("/swagger/", httpSwagger.WrapHandler)

	// Проверка работы
	// @Summary Проверка работоспособности API
	// @Description Возвращает "Hello, World!" для тестирования
	// @Tags         tests
	// @Produce      plain
	// @Success      200  {string}  string  "ok"
	// @Router       /hello [get]
	http.HandleFunc("/api/hello", api.HelloHandler)

	// Вход в аккаунт
	// @Summary      Аутентификация пользователя
	// @Description  Вход по email и паролю, возвращает JWT-токен
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        credentials  body  api.LoginRequest  true  "Email и пароль"
	// @Success      200          {object}  api.LoginResponse
	// @Failure      400          {object}  api.ErrorResponse
	// @Router       /login [post]
	http.HandleFunc("/api/login", api.LoginHandler)

	// Регистрация аккаунта
	// @Summary      Отправка email для регистрации
	// @Description  Проверяет email и отправляет код подтверждения
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        email  body  api.EmailRequest  true  "Email для регистрации"
	// @Success      200    {object}  api.EmailResponse
	// @Failure      400    {object}  api.ErrorResponse
	// @Router       /registration_emailvalidation [post]
	http.HandleFunc("/api/registration_emailvalidation", api.RegistrationHandler_EmailValidation)

	// @Summary      Проверка кода подтверждения
	// @Description  Валидирует код, отправленный на email
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        code  body  api.ValidationCodeRequest  true  "Код подтверждения"
	// @Success      200   {object}  api.ValidationResponse
	// @Failure      400   {object}  api.ErrorResponse
	// @Router       /registration_codevalidation [post]
	http.HandleFunc("/api/registration_codevalidation", api.RegistrationHandler_CodeValidation)

	// @Summary      Установка пароля
	// @Description  Завершает регистрацию, сохраняя пароль
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        password  body  api.PasswordRequest  true  "Новый пароль"
	// @Success      200       {object}  api.RegistrationResponse
	// @Failure      400       {object}  api.ErrorResponse
	// @Router       /registration_password [post]
	http.HandleFunc("/api/registration_password", api.RegistrationHandler_Password)

	// Восстановление пароля
	// @Summary      Запрос на сброс пароля
	// @Description  Отправляет код подтверждения на email
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        email  body  api.EmailRequest  true  "Email для сброса пароля"
	// @Success      200    {object}  api.EmailResponse
	// @Failure      400    {object}  api.ErrorResponse
	// @Router       /forgot_password [post]
	http.HandleFunc("/api/forgot_password", api.PasswordRecovery_ForgotPassword)

	// @Summary      Подтверждение кода для сброса пароля
	// @Description  Проверяет код и разрешает смену пароля
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        code  body  api.ValidationCodeRequest  true  "Код подтверждения"
	// @Success      200   {object}  api.ValidationResponse
	// @Failure      400   {object}  api.ErrorResponse
	// @Router       /commit_code_reset_password [post]
	http.HandleFunc("/api/reset_password", api.PasswordRecovery_ResetPassword)

	// @Summary      Установка нового пароля
	// @Description  Меняет пароль после подтверждения кода
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        new_password  body  api.PasswordRequest  true  "Новый пароль"
	// @Success      200           {object}  api.PasswordResetResponse
	// @Failure      400           {object}  api.ErrorResponse
	// @Router       /reset_password [post]
	http.HandleFunc("/api/commit_code_reset_password", api.PasswordRecovery_CommitCode)

	// Обновление токена
	// @Summary      Обновление JWT-токена
	// @Description  Возвращает новую пару access/refresh токенов
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        refresh_token  body  api.RefreshTokenRequest  true  "Refresh-токен"
	// @Success      200            {object}  api.LoginResponse
	// @Failure      400            {object}  api.ErrorResponse
	// @Router       /refresh_token [post]
	http.HandleFunc("/api/refresh_token", api.RefreshHandler)

	// Добавление анкеты
	// @Summary      Создание новой анкеты
	// @Description  Доступно только аутентифицированным пользователям
	// @Tags         questionnaire
	// @Accept       json
	// @Produce      json
	// @Security     BearerAuth
	// @Param        questionnaire  body  api.QuestionnaireRequest  true  "Данные анкеты"
	// @Success      201            {object}  api.QuestionnaireResponse
	// @Failure      400            {object}  api.ErrorResponse
	// @Failure      401            {object}  api.ErrorResponse
	// @Router       /questionnaire [post]
	//http.HandleFunc("/api/questionnaire", api.AddQuestionnaireHandler)
	http.Handle("/api/questionnaire", auth.Access(http.HandlerFunc(api.AddQuestionnaireHandler)))

	//Добавление или обновление tutor
	http.Handle("/api/add_tutor", auth.Access(http.HandlerFunc(api.ChangeTutorInformation)))

	//Получение информации о tutor
	http.Handle("/api/get_tutor", auth.Access(http.HandlerFunc(api.GetTutorInformation)))

	// Для подтверждения по ссылке
	/* -----------------------------------------------------------------------
		http.Handle("/reset_password_page/",
			http.StripPrefix("/reset_password_page/",
				http.FileServer(http.Dir("html_pages/reset_password_page"))))

		http.Handle("/success_page/",
			http.StripPrefix("/success_page/",
				http.FileServer(http.Dir("html_pages/success_page"))))
	------------------------------------------------------------------------ */

	// Init database
	db, err := sql.Open("postgres", fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
	))

	if err != nil {
		log.Printf("Error with database: %s", err)
		return
	}

	api_email.InitEmailApi(db)
	api.InitDatabase(db)

	mongoURI := os.Getenv("MONGO_URI")
	mongoClient, err := database.ConnectMongo(mongoURI)
	if err != nil {
		log.Fatalf("Could not connect to MongoDB: %v", err)
	} else {
		err := database.CheckConnection(mongoClient)
		if err != nil {
			log.Fatalf("Connection is lost: %v", err)
		}
	}

	log.Println("Server started on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
