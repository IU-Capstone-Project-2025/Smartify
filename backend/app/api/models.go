package api

type success_answer struct {
	Status string `json:"status"`
	Code   int    `json:"code"`
}

type error_answer struct {
	Error string `json:"error"`
	Code  int    `json:"code"`
}

type tokens_answer struct {
	RefreshToken string `json:"refresh_token"`
	AccessToken  string `json:"access_token"`
}

type code_verification struct {
	Email string `json:"email"`
	Code  string `json:"code"`
}

type update_password struct {
	Email       string `json:"email"`
	NewPassword string `json:"newPassword"`
}

type user_email_password struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type refresh_token struct {
	RefreshToken string `json:"refresh_token"`
}

type email_struct struct {
	Email string `json:"email"`
}

type tutor_succes struct {
	Status string `json:"status"`
	Code   int    `json:"code"`
}
