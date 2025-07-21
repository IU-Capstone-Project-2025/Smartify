package api

import (
	"encoding/json"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

// This function was written for the future so there is no Swagger documentation YET
// GiveTutorRole assigns tutor role to the authenticated user
func GiveTutorRole(w http.ResponseWriter, r *http.Request) {
	// Only allow POST requests
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Get user ID from request context (set by auth middleware)
	userIDValue := r.Context().Value(auth.UserIDKey)

	// Check if user is authenticated
	if userIDValue == nil {
		http.Error(w, "User ID not found", http.StatusUnauthorized)
		return
	}

	// Type assert user ID to int
	userID, ok := userIDValue.(int)
	if !ok {
		http.Error(w, "User ID is of invalid type", http.StatusInternalServerError)
		return
	}

	// Find user in database
	var user database.User
	err := database.FindUserByID(userID, &user, db)
	if err != nil {
		http.Error(w, "Database error or user is invalid", http.StatusInternalServerError)
		return
	}

	// Update user role to tutor
	user.User_role = "tutor"

	// Save updated user info
	if err := database.ChangeUserInfo(user, db); err != nil {
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Return success response
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Tutor_succes{Status: "Tutor role given", Code: http.StatusOK})
}

// @Summary      Adding/updating tutor information
// @Description  Available only to authenticated users with the tutor role. Updates or creates a tutor record.
// @Tags         tutor
// @Accept       json
// @Produce      json
// @Param        tutor_data  body      database.Tutor  true  "Tutor data to be updated"
// @Success      200         {object}  Tutor_succes    "Successful data update"
// @Failure      400         {object}  Error_answer    "Invalid data or JSON"
// @Failure      401         {object}  Error_answer    "User not authenticated"
// @Failure      403         {object}  Error_answer    "The user is not a tutor"
// @Failure      405         {object}  Error_answer    "Method not allowed"
// @Failure      500         {object}  Error_answer    "Server error (database, etc.)"
// @Router       /add_tutor [post]
func ChangeTutorInformation(w http.ResponseWriter, r *http.Request) {
	// Only allow POST requests
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	// Get user ID from request context
	userIDValue := r.Context().Value(auth.UserIDKey)

	if userIDValue == nil {
		http.Error(w, "User ID not found", http.StatusUnauthorized)
		return
	}

	// Decode request body into Tutor struct
	var q database.Tutor
	if err := json.NewDecoder(r.Body).Decode(&q); err != nil {
		http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
		return
	}

	// Type assert user ID to int
	userID, ok := userIDValue.(int)
	if !ok {
		http.Error(w, "User ID is of invalid type", http.StatusInternalServerError)
		return
	}

	// Verify user exists and has tutor role
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

	// Set tutor user ID and save to database
	q.UserID = userID
	if err := database.AddTutor(q); err != nil {
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Return success response
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Tutor_succes{Status: "Tutor updated", Code: http.StatusOK})
}

// @Summary      Getting information about the tutor
// @Description  Returns complete information about the current authenticated tutor
// @Tags         tutor
// @Produce      json
// @Success      200  {object}  database.Tutor  "Tutor data"
// @Failure      401  {object}  Error_answer    "User not authenticated"
// @Failure      403  {object}  Error_answer    "The user is not a tutor"
// @Failure      500  {object}  Error_answer    "Server error (database, etc.)"
// @Router       /get_tutor [get]
func GetTutorInformation(w http.ResponseWriter, r *http.Request) {
	// Verify correct HTTP method (should be GET per router annotation)
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Get user ID from request context
	userIDValue := r.Context().Value(auth.UserIDKey)
	if userIDValue == nil {
		http.Error(w, "User ID not found", http.StatusUnauthorized)
		return
	}

	// Type assert user ID to int
	userID, ok := userIDValue.(int)
	if !ok {
		http.Error(w, "User ID is of invalid type", http.StatusInternalServerError)
		return
	}

	// Verify user exists and has tutor role
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

	// Get tutor information from database
	t, err := database.GetTutor(userID)
	if err != nil {
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Return tutor data
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(t)
}
