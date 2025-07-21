package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/ml"
)

// ToQuestionnairePred converts a database Questionnaire to ML prediction format
// by marshaling and unmarshaling between struct types
func ToQuestionnairePred(q database.Questionnaire) (ml.QuestionnairePred, error) {
	var pred ml.QuestionnairePred

	// Marshal the questionnaire to JSON bytes
	data, err := json.Marshal(q)
	if err != nil {
		return pred, err
	}

	// Unmarshal into the prediction format struct
	err = json.Unmarshal(data, &pred)
	return pred, err
}

// ToMongoProf converts ML prediction results to MongoDB storage format
// by mapping each profession prediction to database format
func ToMongoProf(userID int, q []ml.ProfessionPred) (database.ProfessionRec, error) {

	var preds []database.ProfessionPredic

	// Convert each ML prediction to database format
	for _, r := range q {
		p := database.ProfessionPredic{
			Name:        r.Name,
			Score:       r.Score,
			Positives:   r.Positives,
			Negatives:   r.Negatives,
			Description: r.Description,
		}
		preds = append(preds, p)
	}

	// Create complete profession recommendation record
	rec := database.ProfessionRec{
		UserID:           userID,
		ProfessionPredic: preds,
	}
	return rec, nil
}

// @Summary      Creating a new questionnaire
// @Description  Creates a new user profile and returns ML-based occupation recommendations. Authentication required (JWT token in Authorization header)
// @Tags         questionnaire
// @Accept       json
// @Produce      json
// @Param        questionnaire  body      database.Questionnaire  true  "Questionnaire data"
// @Success      200            {object}  ProfessionPredResponse  "Successful response with recommendations of occupations"
// @Failure      400            {string}  string                   "Invalid questionnaire data"
// @Failure      401            {string}  string                   "User not authenticated"
// @Failure      405            {string}  string                   "Method not allowed"
// @Failure      500            {string}  string                   "Server error (database, ML model, etc.)"
// @Router       /questionnaire [post]
func AddQuestionnaireHandler(w http.ResponseWriter, r *http.Request) {
	// Only allow POST requests
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Get user ID from request context (set by auth middleware)
	userIDValue := r.Context().Value(auth.UserIDKey)

	// If no userID, auth middleware didn't run or context is empty
	if userIDValue == nil {
		http.Error(w, "User ID not found", http.StatusUnauthorized)
		return
	}

	// Decode JSON request body into Questionnaire struct
	var q database.Questionnaire
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

	// Set questionnaire user ID
	q.UserID = userID

	// Store questionnaire in database
	if err := database.AddQuestionnaire(q); err != nil {
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Convert questionnaire to ML prediction format
	q_pred, err := ToQuestionnairePred(q)
	if err != nil {
		http.Error(w, "Error converting questionnaire: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Get profession predictions from ML model
	result, err := ml.MLProf(q_pred)
	if err != nil {
		http.Error(w, "Error in ML prediction: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Log prediction results for debugging
	log.Printf("ML prediction result for user %d: %+v\n", userID, result)

	// Convert predictions to MongoDB storage format
	profession_pred_mongo, err := ToMongoProf(userID, result)
	if err != nil {
		http.Error(w, "Error converting profession recommendations: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Store recommendations in database
	database.AddProfessionRecommendation(profession_pred_mongo)
	if err != nil {
		http.Error(w, "Error converting questionnaire: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Return predictions as JSON response
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
