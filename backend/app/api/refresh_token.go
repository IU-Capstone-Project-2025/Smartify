package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

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
func RefreshHandler(w http.ResponseWriter, r *http.Request) {
	// Log new refresh token request
	log.Println("New refresh request!")

	// Set response content type to JSON
	w.Header().Set("Content-Type", "application/json")

	// Verify request method is POST
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	var req Refresh_token

	// Decode JSON request body
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		// Handle invalid JSON request
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid request",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Parse and validate refresh token
	claims, err := auth.ParseToken(req.RefreshToken)
	if err != nil {
		// Handle invalid token format
		log.Println("Invalid refresh token type 1!")
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid refresh token",
			Code:  http.StatusUnauthorized,
		})
		return
	}

	// Check if token exists in database and matches user
	valid, userID, err := database.IsRefreshTokenValid(req.RefreshToken, db)
	if err != nil || !valid || claims.UserID != userID {
		// Handle invalid/expired token or user mismatch
		log.Println("Invalid refresh token type 2!")
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Refresh token expired or invalid",
			Code:  http.StatusUnauthorized,
		})
		return
	}

	// Delete old refresh token from database
	database.DeleteRefreshToken(req.RefreshToken, db)

	// Generate new token pair
	accessToken, newRefreshToken, err := auth.GenerateTokens(userID)
	if err != nil {
		// Handle token generation failure
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Could not generate tokens",
			Code:  http.StatusInternalServerError,
		})
		return
	}

	// Store new refresh token in database
	database.StoreRefreshToken(userID, newRefreshToken, db)

	// Return new token pair
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Tokens_answer{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
	})
}

// @Summary      Logout
// @Description  Deactivates the refresh token, terminating the user session
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request  body      Refresh_token  true  "Refresh token for deactivation"
// @Success      200      {object}  Success_answer "Successful exit"
// @Failure      400      {object}  Error_answer   "Invalid request"
// @Failure      405      {object}  Error_answer   "Method not allowed"
// @Router       /logout [post]
func LogoutHandler(w http.ResponseWriter, r *http.Request) {
	var req Refresh_token

	// Decode refresh token from request body
	json.NewDecoder(r.Body).Decode(&req)

	// Delete refresh token from database
	database.DeleteRefreshToken(req.RefreshToken, db)

	// Return success response
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Success_answer{
		Status: "OK",
		Code:   http.StatusOK,
	})
}
