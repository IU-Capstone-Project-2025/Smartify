package api

import "time"

// Response structures ######################################################

// Success_answer represents a successful API response
type Success_answer struct {
	Status string `json:"status"` // Status message
	Code   int    `json:"code"`   // HTTP status code
}

// Error_answer represents an error API response
type Error_answer struct {
	Error string `json:"error"` // Error message
	Code  int    `json:"code"`  // HTTP status code
}

// Questionnaire data structures ############################################

// QuestionnaireResponse contains all questionnaire response data
type QuestionnaireResponse struct {
	UserID           int                     `json:"user_id" bson:"user_id"`
	Class            string                  `json:"class" bson:"class"`
	Region           string                  `json:"region" bson:"region"`
	AvgGrade         string                  `json:"avg_grade" bson:"avg_grade"`
	FavoriteSubjects []string                `json:"favorite_subjects" bson:"favorite_subjects"`
	HardSubjects     []string                `json:"hard_subjects" bson:"hard_subjects"`
	SubjectScores    map[string]int          `json:"subject_scores" bson:"subject_scores"`
	Interests        []string                `json:"interests" bson:"interests"`
	Values           []string                `json:"values" bson:"values"`
	MBTIScores       map[string]int          `json:"mbti_scores" bson:"mbti_scores"`
	WorkPreferences  WorkPreferencesResponse `json:"work_preferences" bson:"work_preferences"`
	TimeStamp        time.Time               `bson:"timestamp" json:"timestamp"`
}

// WorkPreferencesResponse contains work preference details
type WorkPreferencesResponse struct {
	Role    string `json:"role" bson:"role"`
	Place   string `json:"place" bson:"place"`
	Style   string `json:"style" bson:"style"`
	Exclude string `json:"exclude" bson:"exclude"`
}

// Authentication structures ##############################################

// Tokens_answer contains authentication tokens
type Tokens_answer struct {
	RefreshToken string `json:"refresh_token"`
	AccessToken  string `json:"access_token"`
}

// Refresh_token contains a refresh token for authentication
type Refresh_token struct {
	RefreshToken string `json:"refresh_token"`
}

// User_email_password contains user credentials
type User_email_password struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// Email_struct contains an email address
type Email_struct struct {
	Email string `json:"email"`
}

// Tracker structures ######################################################

// Get_trackers_request contains a token for tracker requests
type Get_trackers_request struct {
	Token string `json:"token"` // Authentication token (Access Token)
}

// Trackers contains a list of user trackers
type Trackers struct {
	Trackers []string `json:"trackers" example:"[tracker1, tracker2]"`
}

// Tracker_save contains tracker data to be saved
type Tracker_save struct {
	Token     string   `json:"token"`
	Timestamp string   `json:"timestamp"`
	Trackers  []string `json:"trackers" example:"[tracker1, tracker2]"`
}

// GetParsedTime converts the Timestamp string to a time.Time object
func (r *Tracker_save) GetParsedTime() (time.Time, error) {
	return time.Parse(time.RFC3339, r.Timestamp)
}

// Verification structures ###############################################

// Code_verification contains email verification data
type Code_verification struct {
	Email string `json:"email"`
	Code  string `json:"code"`
}

// Update_password contains password update data
type Update_password struct {
	Email       string `json:"email"`
	NewPassword string `json:"newPassword"`
}

// Profession prediction structures ######################################

// ProfessionPredResponse contains profession prediction details
type ProfessionPredResponse struct {
	Name        string   `json:"name"`
	Score       float64  `json:"score"`
	Positives   []string `json:"positives"`
	Negatives   []string `json:"negatives"`
	Description string   `json:"description"`
	Subsphere   string   `json:"subsphere"`
}

// Tutor structures ######################################################

// Tutor_succes contains tutor operation success response
type Tutor_succes struct {
	Status string `json:"status"`
	Code   int    `json:"code"`
}
