package api

import (
	"encoding/json"
	"log"
	"net/http"
)

// @Summary      Функция проверки доступности
// @Description  Просто говорит привет, а точнее "ok"
// @Tags         auth
// @Accept       json
// @Produce      json
// @Router       /commit_code_reset_password [post]
func HelloHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	log.Println("New check")

	response := map[string]string{
		"message": "ok",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}
