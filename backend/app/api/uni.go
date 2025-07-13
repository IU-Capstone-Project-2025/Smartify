package api

import (
	"encoding/json"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

func AddUniversityHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Only POST allowed", http.StatusMethodNotAllowed)
		return
	}

	var data map[string]interface{}
	err := json.NewDecoder(r.Body).Decode(&data)
	if err != nil {
		http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
		return
	}

	err1 := database.AddUniversity(data)
	if err1 != nil {
		http.Error(w, "Database error: "+err1.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"status": "University added"})
}

// @Summary Эндпоинт для обновления университетов
// @Description Возвращяет universities.json файл
// @Tags universities
// @Produce json
// @Success 200 {array} database.University "Successfully downloaded universities.json"
// @Failure 400 {string} string "Bad request - Only GET method allowed"
// @Failure 500 {string} string "Internal server error - Failed to send file"
// @Router /update [get]
func RequestToUpdate(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Only GET method allowed", http.StatusMethodNotAllowed)
		return
	}
	universities, err := database.GetAllUniversities()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(universities); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}
