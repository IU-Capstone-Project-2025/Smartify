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
	json.NewEncoder(w).Encode(map[string]string{"status": "Tutor role given"})
}

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
	json.NewEncoder(w).Encode(map[string]string{"status": "Tutor updated"})
}

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
