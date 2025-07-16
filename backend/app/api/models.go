package api

import "time"

type Success_answer struct {
	Status string `json:"status"`
	Code   int    `json:"code"`
}

type Error_answer struct {
	Error string `json:"error"`
	Code  int    `json:"code"`
}

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

type WorkPreferencesResponse struct {
	Role    string `json:"role" bson:"role"`
	Place   string `json:"place" bson:"place"`
	Style   string `json:"style" bson:"style"`
	Exclude string `json:"exclude" bson:"exclude"`
}

type Get_trackers_request struct {
	Token string `json:"token"`
}

type Tokens_answer struct {
	RefreshToken string `json:"refresh_token"`
	AccessToken  string `json:"access_token"`
}

type ProfessionPredResponse struct {
	Name        string   `json:"name"`
	Score       float64  `json:"score"`
	Positives   []string `json:"positives"`
	Negatives   []string `json:"negatives"`
	Description string   `json:"description"`
	Subsphere   string   `json:"subsphere"`
}

type Trackers struct {
	Trackers []string `json:"trackers" example:"[
	{
		title,
		icon,
		color,
		tasks: {
				title,
				duration,
				deadline,
				isCompleted
			}
	},
	{
		title,
		icon,
		color,
		tasks: {
				title,
				duration,
				deadline,
				isCompleted
			}
	}]"`
}

type Code_verification struct {
	Email string `json:"email"`
	Code  string `json:"code"`
}

type Update_password struct {
	Email       string `json:"email"`
	NewPassword string `json:"newPassword"`
}

type User_email_password struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type Refresh_token struct {
	RefreshToken string `json:"refresh_token"`
}

type Email_struct struct {
	Email string `json:"email"`
}

type Tutor_succes struct {
	Status string `json:"status"`
	Code   int    `json:"code"`
}

type Tracker_save struct {
	Token     string   `json:"token"`
	Timestamp string   `json:"timestamp"`
	Trackers  []string `json:"trackers" example:"[
	{
		title,
		icon,
		color,
		tasks: {
				title,
				duration,
				deadline,
				isCompleted
			}
	},
	{
		title,
		icon,
		color,
		tasks: {
				title,
				duration,
				deadline,
				isCompleted
			}
	}]"`
}

func (r *Tracker_save) GetParsedTime() (time.Time, error) {
	return time.Parse(time.RFC3339, r.Timestamp)
}
