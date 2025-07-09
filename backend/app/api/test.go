package api

import (
	"encoding/json"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

func AddQuestionnaireHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userIDValue := r.Context().Value(auth.UserIDKey)

	// Если нет userID — значит middleware не сработал или контекст пустой
	if userIDValue == nil {
		http.Error(w, "User ID not found", http.StatusUnauthorized)
		return
	}

	var q database.Questionnaire
	if err := json.NewDecoder(r.Body).Decode(&q); err != nil {
		http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
		return
	}

	userID, ok := userIDValue.(int)

	if !ok {
		http.Error(w, "User ID is of invalid type", http.StatusInternalServerError)
		return
	}

	q.UserID = userID

	if err := database.AddQuestionnaire(q); err != nil {
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "questionnaire processed"})
}
