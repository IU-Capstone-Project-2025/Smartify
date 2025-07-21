package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

// @Summary      Аутентификация пользователя
// @Description  Проверяет учетные данные пользователя и возвращает пару JWT-токенов (access и refresh)
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        credentials  body      User_email_password  true  "Email и пароль пользователя"
// @Success      200         {object}  Tokens_answer         "Успешная аутентификация, возвращает токены"
// @Failure      400         {object}  Error_answer          "Неверные учетные данные или невалидный запрос"
// @Failure      405         {object}  Error_answer          "Метод не разрешен"
// @Failure      500         {object}  Error_answer          "Ошибка сервера (генерация токенов, проблемы с БД)"
// @Router       /login [post]
func LoginHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("New connection!")
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	var user User_email_password
	// Try to decode message
	err := json.NewDecoder(r.Body).Decode(&user)

	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid JSON",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Print Message
	log.Printf("User: %s, %s", user.Email, user.Password)

	// Find user in database
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

	accessToken, refreshToken, err := auth.GenerateTokens(userDB.ID)
	if err != nil {
		log.Printf("Cannot generate tokens: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Error generating tokens",
			Code:  http.StatusInternalServerError,
		})
		return
	}

	err = database.StoreRefreshToken(userDB.ID, refreshToken, db)
	if err != nil {
		log.Printf("Cannot store refresh token: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Error saving refresh token",
			Code:  http.StatusInternalServerError,
		})
		return
	}

	resp := Tokens_answer{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}

	// Send successful answer
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(resp)
}
