// Package auth provides middleware functions.
package auth

import (
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// Common error values for token validation failures.
var (
	ErrInvalidTokenType = errors.New("invalid token type")
	ErrTokenExpired     = errors.New("token expired")
	ErrInvalidToken     = errors.New("invalid token")
)

// Secret key used for signing JWTs, loaded from environment variable JWT_SECRET.
var (
	jwtKey          = []byte(os.Getenv("JWT_SECRET"))
	accessTokenTTL  = time.Minute * 1
	refreshTokenTTL = time.Hour * 24 * 7
)

// Claims represents the payload stored in the JWT token.
type Claims struct {
	UserID int    `json:"user_id"`
	Type   string `json:"type"`
	jwt.RegisteredClaims
}

// GenerateTokens creates a new access and refresh tokesn for the given user ID.
func GenerateTokens(userID int) (accessToken string, refreshToken string, err error) {
	now := time.Now()

	// Claims for access token
	accessClaims := &Claims{
		UserID: userID,
		Type:   "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(accessTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(now),
		},
	}

	// Claims for refresh token
	refreshClaims := &Claims{
		UserID: userID,
		Type:   "refresh",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(refreshTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(now),
		},
	}

	// Generate signed JWTs using HS256 algorithm
	accessToken, err = jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims).SignedString(jwtKey)
	if err != nil {
		return
	}

	refreshToken, err = jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims).SignedString(jwtKey)
	return
}

// ParseToken verifies and decodes a JWT string into Claims.
// Returns the Claims if the token is valid and matches the expected structure.
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

// ValidateAccessToken validates that a token is a valid access token and not expired.
func ValidateAccessToken(tokenStr string) error {
	claims, err := ParseToken(tokenStr)
	if err != nil {
		return err
	}

	if claims.Type != "access" {
		return ErrInvalidTokenType
	}

	if time.Now().After(claims.ExpiresAt.Time) {
		return ErrTokenExpired
	}

	return nil
}

// ValidateRefreshToken validates that a token is a valid refresh token and not expired.
func ValidateRefreshToken(tokenStr string) error {
	claims, err := ParseToken(tokenStr)
	if err != nil {
		return err
	}

	if claims.Type != "refresh" {
		return ErrInvalidTokenType
	}

	if time.Now().After(claims.ExpiresAt.Time) {
		return ErrTokenExpired
	}

	return nil
}
