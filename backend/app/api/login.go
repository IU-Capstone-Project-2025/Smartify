package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

// @Summary      Аутентификация пользователя
// @Description  Вход по email и паролю, возвращает JWT-токен
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        credentials  body  database.User  true  "Email и пароль"
// @Success		 200 {Object} tokens_answer
// @Failure		 405 {Object} error_answer
// @Failure		 400 {Object} error_answer
// @Failure		 500 {Object} error_answer
// @Router       /login [post]
func LoginHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("New connection!")
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	var user database.User
	// Try to decode message
	err := json.NewDecoder(r.Body).Decode(&user)

	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Invalid JSON",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Print Message
	log.Printf("User: %s, %s", user.Email, user.Password_hash)

	// Find user in database
	err = database.FindAndCheckUser(user.Email, user.Password_hash, &user, db)
	if err != nil {
		log.Printf("Cannot write in database: %s", err)
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Account will not be found...",
			Code:  http.StatusBadRequest,
		})
		return
	}

	accessToken, refreshToken, err := auth.GenerateTokens(user.ID)
	if err != nil {
		log.Printf("Cannot generate tokens: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Error generating tokens",
			Code:  http.StatusInternalServerError,
		})
		return
	}

	err = database.StoreRefreshToken(user.ID, refreshToken, db)
	if err != nil {
		log.Printf("Cannot store refresh token: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Error saving refresh token",
			Code:  http.StatusInternalServerError,
		})
		return
	}

	resp := tokens_answer{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}

	// Send successful answer
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(resp)
}
