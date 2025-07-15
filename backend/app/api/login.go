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
// @Router       /login [post]
func LoginHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("New connection!")
	w.Header().Set("Content-Type", "application/json")

	var user database.User
	// Try to decode message
	err := json.NewDecoder(r.Body).Decode(&user)

	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid JSON",
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
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Account will not be found...",
		})
		return
	}

	accessToken, refreshToken, err := auth.GenerateTokens(user.ID)
	if err != nil {
		log.Printf("Cannot generate tokens: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Error generating tokens",
		})
		return
	}

	err = database.StoreRefreshToken(user.ID, refreshToken, db)
	if err != nil {
		log.Printf("Cannot store refresh token: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Error saving refresh token",
		})
		return
	}

	resp := map[string]string{
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	}

	// Send successful answer
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(resp)
}
