package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

// @Summary      Для сохранения трекеров на сервере
// @Description  Пользовтаель отправляет трекеры с устройства. Сервер записывает их в базуданных, чтобы трекеры были доступны на раззных устройствах
// @Tags         trackers
// @Accept       json
// @Produce      json
// @Param        credentials  body	Tracker_save  true "Токен, время и трекеры"
// @Success		 200 {object} Success_answer
// @Failure		 405 {object} Error_answer
// @Failure		 400 {object} Error_answer
// @Failure		 401 {object} Error_answer
// @Failure		 304 {object} Error_answer
// @Router		 /savetrackers [post]
func SaveTrackers(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

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

	var userTr database.User_trackers
	userTr.UserID = claim.UserID
	userTr.Trackers = request.Trackers
	userTr.TimeStamp = parsedTime

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
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	})
}

// @Summary      Для получения трекеров с сервера
// @Description  Пользовтаель получет трекеры с сервера
// @Tags         trackers
// @Accept       json
// @Produce      json
// @Param        credentials  body	Get_trackers_request  true  "Access Token"
// @Success		 200 {object} Trackers
// @Failure		 405 {object} Error_answer
// @Failure		 400 {object} Error_answer
// @Failure		 401 {object} Error_answer
// @Failure		 304 {object} Error_answer
// @Router		 /gettrackers [post]
func GetTrackers(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		json.NewEncoder(w).Encode(Error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

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

	var userTr database.User_trackers
	userTr.UserID = claim.UserID

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
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Trackers{
		Trackers: trackers.Trackers,
	})
}
