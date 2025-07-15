package ml

import (
	"bytes"
	"encoding/json"
	"net/http"
	"os"
)

type ProfessionPred struct {
	Name        string   `json:"name"`
	Score       float64  `json:"score"`
	Positives   []string `json:"positives"`
	Negatives   []string `json:"negatives"`
	Description string   `json:"description"`
}

type QuestionnairePred struct {
	Class            string          `json:"class" bson:"class"`
	Region           string          `json:"region" bson:"region"`
	AvgGrade         string          `json:"avg_grade" bson:"avg_grade"`
	FavoriteSubjects []string        `json:"favorite_subjects" bson:"favorite_subjects"`
	HardSubjects     []string        `json:"hard_subjects" bson:"hard_subjects"`
	SubjectScores    map[string]int  `json:"subject_scores" bson:"subject_scores"`
	Interests        []string        `json:"interests" bson:"interests"`
	Values           []string        `json:"values" bson:"values"`
	MBTIScores       map[string]int  `json:"mbti_scores" bson:"mbti_scores"`
	WorkPreferences  WorkPreferences `json:"work_preferences" bson:"work_preferences"`
}

type WorkPreferences struct {
	Role    string `json:"role" bson:"role"`
	Place   string `json:"place" bson:"place"`
	Style   string `json:"style" bson:"style"`
	Exclude string `json:"exclude" bson:"exclude"`
}

func MLProf(student QuestionnairePred) ([]ProfessionPred, error) {
	jsonData, err := json.Marshal(student)
	if err != nil {
		return nil, err
	}

	url := os.Getenv("ML_URL")
	if url == "" {
		url = "http://ml:8091"
	}
	url += "/recommend"

	resp, err := http.Post(
		url,
		"application/json",
		bytes.NewBuffer(jsonData),
	)

	if err != nil {
		return nil, err
	}

	var result []ProfessionPred
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return result, err
	}

	return result, nil
}
