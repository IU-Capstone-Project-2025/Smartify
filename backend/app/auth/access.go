// Package auth provides middleware functions.
package auth

import (
	"context"
	"log"
	"net/http"
)

// contextKey is a custom type to avoid key collisions in context.
type contextKey string

// UserIDKey is the context key used to store the authenticated user's ID.
const UserIDKey contextKey = "UserID"

// Access is an HTTP middleware that checks for a valid access token in the request.
// If the token is valid and of type "access", it adds the user ID to the request context.
// Otherwise, it returns an HTTP 401 Unauthorized error.
func Access(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Println("New protected request!")

		// Retrieve the access token from the request header
		authHeader := r.Header.Get("Access_token")
		if authHeader == "" {
			http.Error(w, "Missing or invalid Authorization header", http.StatusUnauthorized)
			return
		}

		tokenStr := authHeader

		// Parse and validate the token
		claims, err := ParseToken(tokenStr)
		if err != nil {
			http.Error(w, "Invalid or expired access token", http.StatusUnauthorized)
			return
		}

		// Ensure the token type is "access"
		if claims.Type != "access" {
			http.Error(w, "Invalid token type", http.StatusUnauthorized)
			return
		}

		// Add the user ID from the token claims to the request context
		ctx := context.WithValue(r.Context(), UserIDKey, claims.UserID)

		// Pass the request to the next handler with the new context
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
