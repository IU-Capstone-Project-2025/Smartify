package api

import (
	"encoding/json"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

// This function was written for the future so there is no Swagger documentation YET
// AddUniversityHandler handles adding a new university to the database
func AddUniversityHandler(w http.ResponseWriter, r *http.Request) {
	// Only allow POST requests
	if r.Method != http.MethodPost {
		http.Error(w, "Only POST allowed", http.StatusMethodNotAllowed)
		return
	}

	// Decode the JSON request body into a map
	var data map[string]interface{}
	err := json.NewDecoder(r.Body).Decode(&data)
	if err != nil {
		http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
		return
	}

	// Add the university to the database
	err1 := database.AddUniversity(data)
	if err1 != nil {
		http.Error(w, "Database error: "+err1.Error(), http.StatusInternalServerError)
		return
	}

	// Return success response with 201 Created status
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"status": "University added"})
}

// @Summary Getting the list of universities in JSON format
// @Description Returns a universities.json file with all universities from the database in a structured format for downloading
// @Tags universities
// @Produce json
// @Success 200 {object} []map[string]interface{} "JSON file with university data"
// @Failure 400 {string} string "Плохой запрос - разрешен только метод GET"
// @Failure 500 {string} string "Internal server error - Failed to generate or send file"
// @Header 200 {string} Content-Disposition "attachment; filename=universities.json"
// @Header 200 {string} Content-Type "application/json"
// @Router /update_university_json [get]
func RequestToUpdate(w http.ResponseWriter, r *http.Request) {
	// Retrieve all universities from database
	universities, err := database.GetAllUniversities()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Transform data into export format
	var exportData []map[string]interface{}
	for _, uni := range universities {
		item := map[string]interface{}{
			"ссылка":                 uni.Link,
			"название":               uni.Name,
			"регион":                 uni.Region,
			"город":                  uni.City,
			"год основания":          uni.FoundationYear,
			"общежитие":              uni.Dormitory,
			"государственный":        uni.IsState,
			"воен. уч. центр":        uni.HasMilitaryDepartment,
			"бюджетные места":        uni.HasBudgetPlaces,
			"лицензия/аккредитация":  uni.IsAccredited,
			"рейтинг":                uni.Rating,
			"учащихся":               uni.StudentsCount,
			"бюджетных мест":         uni.BudgetPlaces,
			"платных мест":           uni.PaidPlaces,
			"самая низкая стоимость": uni.MinPrice,
			"фото":                   uni.PhotoURL,
			"телефон":                uni.Phone,
			"адрес":                  uni.Address,
			"факультеты":             uni.Faculties,
			"проходные_баллы":        uni.PassingScores,
		}
		exportData = append(exportData, item)
	}

	// Set download headers
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Content-Disposition", "attachment; filename=universities.json")

	// Encode data to JSON with pretty printing
	encoder := json.NewEncoder(w)
	encoder.SetIndent("", "  ")
	if err := encoder.Encode(exportData); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}
