package api

import (
	"encoding/json"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

func GiveTutorRole(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userIDValue := r.Context().Value(auth.UserIDKey)

	if userIDValue == nil {
		http.Error(w, "User ID not found", http.StatusUnauthorized)
		return
	}

	userID, ok := userIDValue.(int)

	if !ok {
		http.Error(w, "User ID is of invalid type", http.StatusInternalServerError)
		return
	}

	var user database.User

	err := database.FindUserByID(userID, &user, db)

	if err != nil {
		http.Error(w, "Database error or user is invalid", http.StatusInternalServerError)
		return
	}

	user.User_role = "tutor"

	if err := database.ChangeUserInfo(user, db); err != nil {
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Tutor_succes{Status: "Tutor role given", Code: http.StatusOK})
}

// @Summary      Добавление/обновление информации о тьюторе
// @Description  Доступно только аутентифицированным пользователям с ролью тьютора. Обновляет или создает запись тьютора.
// @Tags         tutor
// @Accept       json
// @Produce      json
// @Param        tutor_data  body      database.Tutor  true  "Данные тьютора для обновления"
// @Success      200         {object}  Tutor_succes    "Успешное обновление данных"
// @Failure      400         {object}  Error_answer    "Невалидные данные или JSON"
// @Failure      401         {object}  Error_answer    "Пользователь не аутентифицирован"
// @Failure      403         {object}  Error_answer    "Пользователь не является тьютором"
// @Failure      405         {object}  Error_answer    "Метод не разрешен"
// @Failure      500         {object}  Error_answer    "Ошибка сервера (БД и т.д.)"
// @Router       /add_tutor [post]
func ChangeTutorInformation(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userIDValue := r.Context().Value(auth.UserIDKey)

	if userIDValue == nil {
		http.Error(w, "User ID not found", http.StatusUnauthorized)
		return
	}

	var q database.Tutor
	if err := json.NewDecoder(r.Body).Decode(&q); err != nil {
		http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
		return
	}

	userID, ok := userIDValue.(int)

	if !ok {
		http.Error(w, "User ID is of invalid type", http.StatusInternalServerError)
		return
	}

	var user database.User

	err := database.FindUserByID(userID, &user, db)

	if err != nil {
		http.Error(w, "Database error or user is invalid", http.StatusInternalServerError)
		return
	}

	if user.User_role != "tutor" {
		http.Error(w, "User isn't tutor", http.StatusInternalServerError)
		return
	}

	q.UserID = userID

	if err := database.AddTutor(q); err != nil {
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Tutor_succes{Status: "Tutor updated", Code: http.StatusOK})
}

// @Summary      Получение информации о тьюторе
// @Description  Возвращает полную информацию о текущем аутентифицированном тьюторе
// @Tags         tutor
// @Produce      json
// @Success      200  {object}  database.Tutor  "Данные тьютора"
// @Failure      401  {object}  Error_answer    "Пользователь не аутентифицирован"
// @Failure      403  {object}  Error_answer    "Пользователь не является тьютором"
// @Failure      500  {object}  Error_answer    "Ошибка сервера (БД и т.д.)"
// @Router       /get_tutor [get]
func GetTutorInformation(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userIDValue := r.Context().Value(auth.UserIDKey)

	if userIDValue == nil {
		http.Error(w, "User ID not found", http.StatusUnauthorized)
		return
	}

	userID, ok := userIDValue.(int)

	if !ok {
		http.Error(w, "User ID is of invalid type", http.StatusInternalServerError)
		return
	}

	var user database.User

	err := database.FindUserByID(userID, &user, db)

	if err != nil {
		http.Error(w, "Database error or user is invalid", http.StatusInternalServerError)
		return
	}

	if user.User_role != "tutor" {
		http.Error(w, "User isn't tutor", http.StatusInternalServerError)
		return
	}

	t, err := database.GetTutor(userID)
	if err != nil {
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(t)
}
