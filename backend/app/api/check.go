package api

import (
	"encoding/json"
	"log"
	"net/http"
)

// @Summary      Функция проверки доступности
// @Description  Просто говорит привет, а точнее "ok"
// @Tags         test
// @Accept       json
// @Produce      json
// @Success		 200 {Object} success_answer
// @Failure		 405 {Object} error_answer
// @Router       /api/hello [get]
func HelloHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(error_answer{
			Error: "Method not allowed",
			Code:  http.StatusMethodNotAllowed,
		})
		return
	}

	log.Println("New check")

	response := success_answer{
		Status: "ok",
		Code:   http.StatusOK,
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}
