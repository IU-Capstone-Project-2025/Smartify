package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

// @Summary      Обновление JWT-токена
// @Description  Возвращает новую пару access/refresh токенов
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        credentials  body  refresh_token  true  "refresh token"
// @Success		 200 {Object} tokens_answer
// @Failure		 405 {Object} error_answer
// @Failure		 400 {Object} error_answer
// @Failure		 401 {Object} error_answer
// @Failure		 500 {Object} error_answer
// @Router       /refresh_token [post]
func RefreshHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("New refresh request!")
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	var req refresh_token
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Invalid request",
			Code:  http.StatusBadRequest,
		})
		return
	}

	claims, err := auth.ParseToken(req.RefreshToken)
	if err != nil {
		log.Println("Invalid refresh token type 1!")
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Invalid refresh token",
			Code:  http.StatusUnauthorized,
		})
		return
	}

	valid, userID, err := database.IsRefreshTokenValid(req.RefreshToken, db)
	if err != nil || !valid || claims.UserID != userID {
		log.Println("Invalid refresh token type 2!")
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Refresh token expired or invalid",
			Code:  http.StatusUnauthorized,
		})
		return
	}

	database.DeleteRefreshToken(req.RefreshToken, db)

	accessToken, newRefreshToken, err := auth.GenerateTokens(userID)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Could not generate tokens",
			Code:  http.StatusInternalServerError,
		})
		return
	}

	database.StoreRefreshToken(userID, newRefreshToken, db)

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(tokens_answer{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
	})
}

// @Summary      Обновление JWT-токена
// @Description  Возвращает новую пару access/refresh токенов
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        credentials  body refresh_token  true  "refresh token"
// @Success		 200 {Object} success_answer
// @Router       /refresh_token [post]
func LogoutHandler(w http.ResponseWriter, r *http.Request) {
	var req refresh_token
	json.NewDecoder(r.Body).Decode(&req)
	database.DeleteRefreshToken(req.RefreshToken, db)
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(success_answer{
		Status: "OK",
		Code:   http.StatusOK,
	})
}
