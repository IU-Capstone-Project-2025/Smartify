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
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/parsers"
	httpSwagger "github.com/swaggo/http-swagger"
)

// @title           Smartify Backend API
// @version         1.1
// @description     REST API for external devices to access the internal Smartify system

// @contact.name   Smartify Working Mail
// @contact.email  smartifyprojectapp@gmail.com

// @host      213.226.112.206:22025
// @BasePath  /api

func main() {

	mux := http.NewServeMux()

	mux.Handle("/swagger/", httpSwagger.WrapHandler)

	// @Summary      Checking server availability
	// @Description  Returns the status “ok” if the server is running
	// @Tags         utils
	// @Produce      json
	// @Success      200 {object} Success_answer "The server is available"
	// @Failure      405 {object} Error_answer   "Method not allowed"
	// @Router       /hello [get]
	mux.HandleFunc("/api/hello", api.HelloHandler)

	// @Summary      User Authentication
	// @Description  Validates user credentials and returns a pair of JWT tokens (access and refresh)
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        credentials  body      User_email_password  true  "User Email and Password"
	// @Success      200         {object}  Tokens_answer         "Successful authentication, returns tokens"
	// @Failure      400         {object}  Error_answer          "Invalid credentials or invalid request"
	// @Failure      405         {object}  Error_answer          "Method not allowed"
	// @Failure      500         {object}  Error_answer          "Server error (token generation, database problems)"
	// @Router       /login [post]
	mux.HandleFunc("/api/login", api.LoginHandler)

	// @Summary      Email validation during registration
	// @Description  Checks the validity of the email and sends a confirmation code. Email must not be already registered.
	// @Tags         registration
	// @Accept       json
	// @Produce      json
	// @Param        request  body      Email_struct    true  "User Email"
	// @Success      200     {object}  Success_answer  "Confirmation code sent"
	// @Failure      400     {object}  Error_answer    "Invalid email or request"
	// @Failure      409     {object}  Error_answer    "The user already exists"
	// @Failure      500     {object}  Error_answer    "Server error (code generation, sending email)"
	// @Router       /registration_emailvalidation [post]
	mux.HandleFunc("/api/registration_emailvalidation", api.RegistrationHandler_EmailValidation)

	// @Summary      Verifying the confirmation code
	// @Description  Validates the code sent to the user's email address
	// @Tags         registration
	// @Accept       json
	// @Produce      json
	// @Param        request  body      Code_verification  true  "Email and confirmation code"
	// @Success      200     {object}  Success_answer      "Code confirmed"
	// @Failure      400     {object}  Error_answer        "Invalid code or user not found"
	// @Failure      405     {object}  Error_answer        "Method not allowed"
	// @Router       /registration_codevalidation [post]
	mux.HandleFunc("/api/registration_codevalidation", api.RegistrationHandler_CodeValidation)

	// @Summary      Finalizing registration
	// @Description  Saves the user password and issues access tokens
	// @Tags         registration
	// @Accept       json
	// @Produce      json
	// @Param        request  body      User_email_password  true  "User Email and Password"
	// @Success      200     {object}  Tokens_answer         "Access tokens"
	// @Failure      400     {object}  Error_answer          "Invalid data or user not found"
	// @Failure      405     {object}  Error_answer          "Method not allowed"
	// @Failure      500     {object}  Error_answer          "Server error (database, token generation)"
	// @Router       /registration_password [post]
	mux.HandleFunc("/api/registration_password", api.RegistrationHandler_Password)

	// @Summary      Password reset request
	// @Description  Sends a confirmation code to the user's email for password recovery
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        request  body      Email_struct    true  "User Email"
	// @Success      200     {object}  Success_answer  "Confirmation code sent"
	// @Failure      400     {object}  Error_answer    "Invalid request or user not found"
	// @Failure      405     {object}  Error_answer    "Method not allowed"
	// @Router       /forgot_password [post]
	mux.HandleFunc("/api/forgot_password", api.PasswordRecovery_ForgotPassword)

	// @Summary      Setting a new password
	// @Description  Sets a new password after successful verification of the confirmation code
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        request  body      Update_password  true  "Email and new password"
	// @Success      200     {object}  Success_answer   "Password successfully changed"
	// @Failure      400     {object}  Error_answer     "Invalid password request or update error"
	// @Failure      405     {object}  Error_answer     "Method not allowed"
	// @Router       /reset_password [post]
	mux.HandleFunc("/api/reset_password", api.PasswordRecovery_ResetPassword)

	// @Summary      Verifying the confirmation code
	// @Description  Validates the password reset code sent to email
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        request  body      Code_verification  true  "Email and confirmation code"
	// @Success      200     {object}  Success_answer      "Code confirmed"
	// @Failure      400     {object}  Error_answer        "Invalid code or user not found"
	// @Failure      405     {object}  Error_answer        "Method not allowed"
	// @Router       /commit_code_reset_password [post]
	mux.HandleFunc("/api/commit_code_reset_password", api.PasswordRecovery_CommitCode)

	// @Summary      JWT Token Update
	// @Description  Returns a new access/refresh token pair using a valid refresh token. The old refresh token becomes invalid.
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        request  body      Refresh_token  true  "Refresh token to update"
	// @Success      200      {object}  Tokens_answer  "A new pair of tokens"
	// @Failure      400      {object}  Error_answer   "Invalid request"
	// @Failure      401      {object}  Error_answer   "Invalid or expired refresh token"
	// @Failure      405      {object}  Error_answer   "Method not allowed"
	// @Failure      500      {object}  Error_answer   "Server error (token generation, database)"
	// @Router       /refresh_token [post]
	mux.HandleFunc("/api/refresh_token", api.RefreshHandler)

	// @Summary      Creating a new questionnaire
	// @Description  Creates a new user profile and returns ML-based occupation recommendations. Authentication required (JWT token in Authorization header)
	// @Tags         questionnaire
	// @Accept       json
	// @Produce      json
	// @Param        questionnaire  body      database.Questionnaire  true  "Questionnaire data"
	// @Success      200            {object}  ProfessionPredResponse  "Successful response with recommendations of occupations"
	// @Failure      400            {string}  string                   "Invalid questionnaire data"
	// @Failure      401            {string}  string                   "User not authenticated"
	// @Failure      405            {string}  string                   "Method not allowed"
	// @Failure      500            {string}  string                   "Server error (database, ML model, etc.)"
	// @Router       /questionnaire [post]
	mux.Handle("/api/questionnaire", auth.Access(http.HandlerFunc(api.AddQuestionnaireHandler)))

	// @Summary      Adding/updating tutor information
	// @Description  Available only to authenticated users with the tutor role. Updates or creates a tutor record.
	// @Tags         tutor
	// @Accept       json
	// @Produce      json
	// @Param        tutor_data  body      database.Tutor  true  "Tutor data to be updated"
	// @Success      200         {object}  Tutor_succes    "Successful data update"
	// @Failure      400         {object}  Error_answer    "Invalid data or JSON"
	// @Failure      401         {object}  Error_answer    "User not authenticated"
	// @Failure      403         {object}  Error_answer    "The user is not a tutor"
	// @Failure      405         {object}  Error_answer    "Method not allowed"
	// @Failure      500         {object}  Error_answer    "Server error (database, etc.)"
	// @Router       /add_tutor [post]
	mux.Handle("/api/add_tutor", auth.Access(http.HandlerFunc(api.ChangeTutorInformation)))

	// @Summary      Getting information about the tutor
	// @Description  Returns complete information about the current authenticated tutor
	// @Tags         tutor
	// @Produce      json
	// @Success      200  {object}  database.Tutor  "Tutor data"
	// @Failure      401  {object}  Error_answer    "User not authenticated"
	// @Failure      403  {object}  Error_answer    "The user is not a tutor"
	// @Failure      500  {object}  Error_answer    "Server error (database, etc.)"
	// @Router       /get_tutor [get]
	mux.Handle("/api/get_tutor", auth.Access(http.HandlerFunc(api.GetTutorInformation)))

	// GetTeachersHandler handles HTTP requests to retrieve all teachers
	// @Summary Get all teachers
	// @Description Retrieves a list of all teachers from the database
	// @Tags teachers
	// @Produce json
	// @Success 200 {array} database.Teacher "List of teachers"
	// @Failure 500 {object} string "Internal server error"
	// @Router /get_teachers [get]
	mux.Handle("/api/get_teachers", auth.Access(http.HandlerFunc(api.GetTeachersHandler)))

	// @Summary Getting the list of universities in JSON format
	// @Description Returns a universities.json file with all universities from the database in a structured format for downloading
	// @Tags universities
	// @Produce json
	// @Success 200 {object} []map[string]interface{} "JSON file with university data"
	// @Failure 400 {string} string "Плохой запрос - разрешен только метод GET"
	// @Failure 500 {string} string "Internal server error - Failed to generate or send file"
	// @Header 200 {string} Content-Disposition "attachment; filename=universities.json"
	// @Header 200 {string} Content-Type "application/json"
	// @Router /update_university_json [get]
	mux.HandleFunc("/api/update_university_json", api.RequestToUpdate)

	// @Summary      Saving user trackers
	// @Description  Saves the user's trackers on the server for synchronization between devices. Requires valid access token and correct timestamp.
	// @Tags         trackers
	// @Accept       json
	// @Produce      json
	// @Param        request  body      Tracker_save      true  "Data to be saved (token, trackers and timestamp)"
	// @Success      200      {object}  Success_answer    "Trackers successfully saved"
	// @Failure      304      {object}  Error_answer      "The data has not been modified (Not Modified)"
	// @Failure      400      {object}  Error_answer      "Invalid request (incorrect data or time format)"
	// @Failure      401      {object}  Error_answer      "Unauthorized access (invalid token)"
	// @Failure      405      {object}  Error_answer      "Method not allowed"
	// @Router       /savetrackers [post]
	mux.HandleFunc("/api/savetrackers", api.SaveTrackers)

	// @Summary      Retrieving user trackers
	// @Description  Returns a list of trackers for an authenticated user. Valid access token is required.
	// @Tags         trackers
	// @Accept       json
	// @Produce      json
	// @Param        request  body      Get_trackers_request  true  "Request with access token"
	// @Success      200      {object}  Trackers              "Successful response with trackers"
	// @Failure      304      {object}  Error_answer          "The data has not been modified (Not Modified)"
	// @Failure      400      {object}  Error_answer          "Invalid request"
	// @Failure      401      {object}  Error_answer          "Unauthorized access (invalid token)"
	// @Failure      405      {object}  Error_answer          "Method not allowed"
	// @Router       /gettrackers [post]
	mux.HandleFunc("/api/gettrackers", api.GetTrackers)

	// @Summary      Checking token validity
	// @Description  Checks the expiration date of access and refresh tokens
	// @Tags         auth
	// @Accept       json
	// @Produce      json
	// @Param        tokens  body      Tokens_answer  true  "A couple of tokens to check out"
	// @Success      200     {object}  Success_answer "The tokens are valid"
	// @Failure      400     {object}  Error_answer   "Invalid request"
	// @Failure      401     {object}  Error_answer   "Tokens are invalid or expired"
	// @Failure      405     {object}  Error_answer   "Method not allowed"
	// @Router       /checkTokens [post]
	mux.HandleFunc("/api/checktokens", api.TokenCheck)

	corsMux := EnableCORS(mux)

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

	parsers.StartTeacherParserTicker(24)

	log.Println("Server started on :8080")
	log.Fatal(http.ListenAndServe(":8080", corsMux))
}

func EnableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		allowedOrigins := []string{
			"http://213.226.112.206:22030", // Website (frontend)
		}

		origin := r.Header.Get("Origin")
		isAllowed := false

		for _, allowed := range allowedOrigins {
			if origin == allowed {
				isAllowed = true
				break
			}
		}

		if isAllowed {
			w.Header().Set("Access-Control-Allow-Origin", origin)
		}

		// Allow methods
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH")

		// Allow ALL necessary headers (including custom headers)
		w.Header().Set("Access-Control-Allow-Headers",
			"Content-Type, Authorization, access_token, X-Requested-With")

		// Allow cookies and authorization headers
		w.Header().Set("Access-Control-Allow-Credentials", "true")

		// Caching of preflight request (optional)
		w.Header().Set("Access-Control-Max-Age", "86400")

		// For preflight requests (OPTIONS)
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}
