package auth

import (
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

var (
	jwtKey          = []byte(os.Getenv("JWT_SECRET"))
	accessTokenTTL  = time.Minute * 1
	refreshTokenTTL = time.Hour * 24 * 7
)

type Claims struct {
	UserID int    `json:"user_id"`
	Type   string `json:"type"`
	jwt.RegisteredClaims
}

func GenerateTokens(userID int) (accessToken string, refreshToken string, err error) {
	now := time.Now()

	accessClaims := &Claims{
		UserID: userID,
		Type:   "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(accessTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(now),
		},
	}

	refreshClaims := &Claims{
		UserID: userID,
		Type:   "refresh",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(refreshTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(now),
		},
	}

	accessToken, err = jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims).SignedString(jwtKey)
	if err != nil {
		return
	}

	refreshToken, err = jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims).SignedString(jwtKey)
	return
}

func ParseToken(tokenStr string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenStr, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return jwtKey, nil
	})

	if err != nil {
		return nil, err
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, err
	}

	return claims, nil
}
