package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

// @Summary      Saving user trackers
// @Description  Saves the user's trackers on the server for synchronization between devices. Requires valid access token and correct timestamp.
// @Tags         trackers
// @Accept       json
// @Produce      json
// @Param        request  body      Tracker_save      true  "Data to be saved (token, trackers and timestamp)"
// @Success      200      {object}  Success_answer    "Trackers successfully saved"
// @Failure      304      {object}  Error_answer      "The data has not been modified (Not Modified)"
// @Failure      400      {object}  Error_answer      "Invalid request (incorrect data or time format)"
// @Failure      401      {object}  Error_answer      "Unauthorized access (invalid token)"
// @Failure      405      {object}  Error_answer      "Method not allowed"
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

// @Summary      Retrieving user trackers
// @Description  Returns a list of trackers for an authenticated user. Valid access token is required.
// @Tags         trackers
// @Accept       json
// @Produce      json
// @Param        request  body      Get_trackers_request  true  "Request with access token"
// @Success      200      {object}  Trackers              "Successful response with trackers"
// @Failure      304      {object}  Error_answer          "The data has not been modified (Not Modified)"
// @Failure      400      {object}  Error_answer          "Invalid request"
// @Failure      401      {object}  Error_answer          "Unauthorized access (invalid token)"
// @Failure      405      {object}  Error_answer          "Method not allowed"
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
