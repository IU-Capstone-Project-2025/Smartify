package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
)

// @Summary      Checking server availability
// @Description  Returns the status “ok” if the server is running
// @Tags         utils
// @Produce      json
// @Success      200 {object} Success_answer "The server is available"
// @Failure      405 {object} Error_answer   "Method not allowed"
// @Router       /hello [get]
func HelloHandler(w http.ResponseWriter, r *http.Request) {
	// Check if request method is GET
	if r.Method != http.MethodGet {
		// Return 405 Method Not Allowed if not GET
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	// Log server health check request
	log.Println("New check")

	// Prepare success response structure
	response := Success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	}

	// Set response headers and encode JSON response
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

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
func TokenCheck(w http.ResponseWriter, r *http.Request) {
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

	var tokens Tokens_answer
	// Parse JSON body into tokens structure
	err := json.NewDecoder(r.Body).Decode(&tokens)
	if err != nil {
		// Handle JSON parsing error
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Code does not equal...",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Validate refresh token first
	err = auth.ValidateRefreshToken(tokens.RefreshToken)
	if err != nil {
		// Handle invalid refresh token
		log.Println("Refresh token is old: " + err.Error())
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Refresh Token is old",
			Code:  http.StatusUnauthorized,
		})
		return
	}

	// Validate access token
	err = auth.ValidateAccessToken(tokens.AccessToken)
	if err != nil {
		// Handle invalid access token
		log.Println("Access token is old: " + err.Error())
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Access Token is old",
			Code:  http.StatusUnauthorized,
		})
		return
	}

	// Prepare success response for valid tokens
	response := Success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	}

	// Send successful validation response
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}
