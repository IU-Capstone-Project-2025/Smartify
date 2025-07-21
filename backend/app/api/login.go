package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

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
func LoginHandler(w http.ResponseWriter, r *http.Request) {
	// Log new connection attempt
	log.Println("New connection!")

	// Set response content type to JSON
	w.Header().Set("Content-Type", "application/json")

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

	var user User_email_password
	// Attempt to decode JSON request body
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

	// Log received credentials (for debugging, remove in production)
	log.Printf("User: %s, %s", user.Email, user.Password)

	// Verify user credentials against database
	var userDB database.User
	err = database.FindAndCheckUser(user.Email, user.Password, &userDB, db)
	if err != nil {
		log.Printf("Cannot write in database: %s", err)
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Account will not be found...",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Generate new JWT tokens for authenticated user
	accessToken, refreshToken, err := auth.GenerateTokens(userDB.ID)
	if err != nil {
		// Handle token generation failure
		log.Printf("Cannot generate tokens: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Error generating tokens",
			Code:  http.StatusInternalServerError,
		})
		return
	}

	// Store refresh token in database
	err = database.StoreRefreshToken(userDB.ID, refreshToken, db)
	if err != nil {
		// Handle token storage failure
		log.Printf("Cannot store refresh token: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Error saving refresh token",
			Code:  http.StatusInternalServerError,
		})
		return
	}

	// Prepare successful response with tokens
	resp := Tokens_answer{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}

	// Send successful authentication response
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(resp)
}
