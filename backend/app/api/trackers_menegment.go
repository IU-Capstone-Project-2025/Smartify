package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

// @Summary      Сохранение трекеров пользователя
// @Description  Сохраняет трекеры пользователя на сервере для синхронизации между устройствами. Требуется валидный access token и корректная метка времени.
// @Tags         trackers
// @Accept       json
// @Produce      json
// @Param        request  body      Tracker_save      true  "Данные для сохранения (токен, трекеры и метка времени)"
// @Success      200      {object}  Success_answer    "Трекеры успешно сохранены"
// @Failure      304      {object}  Error_answer      "Данные не были изменены (Not Modified)"
// @Failure      400      {object}  Error_answer      "Невалидный запрос (некорректные данные или формат времени)"
// @Failure      401      {object}  Error_answer      "Неавторизованный доступ (невалидный токен)"
// @Failure      405      {object}  Error_answer      "Метод не разрешен"
// @Router       /savetrackers [post]
func SaveTrackers(w http.ResponseWriter, r *http.Request) {
	// Only allow POST requests
	if r.Method != http.MethodPost {
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	// Decode request body into Tracker_save struct
	var request Tracker_save
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid request",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Parse and validate JWT token
	claim, err := auth.ParseToken(request.Token)
	if err != nil {
		log.Println("Cannot decode request: " + err.Error())
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid Token. Try to refresh your registration",
			Code:  http.StatusUnauthorized,
		})
		return
	}

	// Parse timestamp from request
	parsedTime, err := request.GetParsedTime()
	if err != nil {
		log.Println("Invalid time format" + err.Error())
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid time format",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Prepare tracker data for database
	var userTr database.User_trackers
	userTr.UserID = claim.UserID
	userTr.Trackers = request.Trackers
	userTr.TimeStamp = parsedTime

	// Save trackers to database
	err = database.AddTrackers(userTr)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusNotModified)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Error with database",
			Code:  http.StatusNotModified,
		})
		return
	}

	// Return success response
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	})
}

// @Summary      Получение трекеров пользователя
// @Description  Возвращает список трекеров для аутентифицированного пользователя. Требуется валидный access token.
// @Tags         trackers
// @Accept       json
// @Produce      json
// @Param        request  body      Get_trackers_request  true  "Запрос с access token"
// @Success      200      {object}  Trackers              "Успешный ответ с трекерами"
// @Failure      304      {object}  Error_answer          "Данные не были изменены (Not Modified)"
// @Failure      400      {object}  Error_answer          "Невалидный запрос"
// @Failure      401      {object}  Error_answer          "Неавторизованный доступ (невалидный токен)"
// @Failure      405      {object}  Error_answer          "Метод не разрешен"
// @Router       /gettrackers [post]
func GetTrackers(w http.ResponseWriter, r *http.Request) {
	// Only allow POST requests
	if r.Method != http.MethodPost {
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	// Decode request body into Get_trackers_request struct
	var request Get_trackers_request
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid request",
			Code:  http.StatusBadRequest,
		})
		return
	}

	// Parse and validate JWT token
	claim, err := auth.ParseToken(request.Token)
	if err != nil {
		log.Println("Cannot decode request: " + err.Error())
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Invalid Token. Try to refresh your registration",
			Code:  http.StatusUnauthorized,
		})
		return
	}

	// Prepare user data for database query
	var userTr database.User_trackers
	userTr.UserID = claim.UserID

	// Retrieve trackers from database
	trackers, err := database.GetTrackers(userTr)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusNotModified)
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Error with database",
			Code:  http.StatusNotModified,
		})
		return
	}

	// Return trackers in response
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Trackers{
		Trackers: trackers.Trackers,
	})
}
