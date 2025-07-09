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
)

func main() {
	// Проверка работы
	http.HandleFunc("/api/hello", api.HelloHandler)

	// Вход в аккаунт
	http.HandleFunc("/api/login", api.LoginHandler)

	// Регистрация аккаунта
	http.HandleFunc("/api/registration_emailvalidation", api.RegistrationHandler_EmailValidation)
	http.HandleFunc("/api/registration_codevalidation", api.RegistrationHandler_CodeValidation)
	http.HandleFunc("/api/registration_password", api.RegistrationHandler_Password)

	// Восстановление пароля
	http.HandleFunc("/api/forgot_password", api.PasswordRecovery_ForgotPassword)
	http.HandleFunc("/api/reset_password", api.PasswordRecovery_ResetPassword)
	http.HandleFunc("/api/commit_code_reset_password", api.PasswordRecovery_CommitCode)

	// Обновление токена
	http.HandleFunc("/api/refresh_token", api.RefreshHandler)

	// Добавление анкеты
	//http.HandleFunc("/api/questionnaire", api.AddQuestionnaireHandler)
	http.Handle("/api/questionnaire", auth.Access(http.HandlerFunc(api.AddQuestionnaireHandler)))

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
