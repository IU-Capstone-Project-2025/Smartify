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
	universities, err := database.GetAllUniversities()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Преобразуем данные в нужный формат
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

	// Устанавливаем заголовки для скачивания файла
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Content-Disposition", "attachment; filename=universities.json")

	// Кодируем данные в JSON с отступами
	encoder := json.NewEncoder(w)
	encoder.SetIndent("", "  ")
	if err := encoder.Encode(exportData); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}
