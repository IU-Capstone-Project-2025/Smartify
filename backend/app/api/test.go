package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/ml"
)

func ToQuestionnairePred(q database.Questionnaire) (ml.QuestionnairePred, error) {
	var pred ml.QuestionnairePred

	data, err := json.Marshal(q)
	if err != nil {
		return pred, err
	}

	err = json.Unmarshal(data, &pred)
	return pred, err
}

func ToMongoProf(userID int, q []ml.ProfessionPred) (database.ProfessionRec, error) {

	var preds []database.ProfessionPredic

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

	rec := database.ProfessionRec{
		UserID:           userID,
		ProfessionPredic: preds,
	}
	return rec, nil
}

// @Summary      Создание новой анкеты
// @Description  Доступно только аутентифицированным пользователям
// @Tags         questionnaire
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Router       /questionnaire [post]
// http.HandleFunc("/api/questionnaire", api.AddQuestionnaireHandler)
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

	q_pred, err := ToQuestionnairePred(q)

	if err != nil {
		http.Error(w, "Error converting questionnaire: "+err.Error(), http.StatusInternalServerError)
		return
	}

	result, err := ml.MLProf(q_pred)

	if err != nil {
		http.Error(w, "Error in ML prediction: "+err.Error(), http.StatusInternalServerError)
		return
	}

	log.Printf("ML prediction result for user %d: %+v\n", userID, result)

	profession_pred_mongo, err := ToMongoProf(userID, result)

	if err != nil {
		http.Error(w, "Error converting profession recommendations: "+err.Error(), http.StatusInternalServerError)
		return
	}

	database.AddProfessionRecommendation(profession_pred_mongo)

	if err != nil {
		http.Error(w, "Error converting questionnaire: "+err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
