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

type Get_trackers_request struct {
	Token string `json:"token"`
}

type Tokens_answer struct {
	RefreshToken string `json:"refresh_token"`
	AccessToken  string `json:"access_token"`
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
