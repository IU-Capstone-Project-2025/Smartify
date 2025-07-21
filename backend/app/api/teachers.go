package api

import (
	"encoding/json"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

// GetTeachersHandler handles HTTP requests to retrieve all teachers
// @Summary Get all teachers
// @Description Retrieves a list of all teachers from the database
// @Tags teachers
// @Produce json
// @Success 200 {array} database.Teacher "List of teachers"
// @Failure 500 {object} string "Internal server error"
// @Router /get_teachers [get]
func GetTeachersHandler(w http.ResponseWriter, r *http.Request) {
	// Retrieve all teachers from the database
	teachers, err := database.GetAllTeachers()
	if err != nil {
		// Return 500 Internal Server Error if database operation fails
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Set response content type to JSON
	w.Header().Set("Content-Type", "application/json")

	// Encode teachers data as JSON and send response
	json.NewEncoder(w).Encode(teachers)
}
