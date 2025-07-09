#!/bin/bash
set -e

echo "Running login test..."

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@mail.com", "password":"Loh1725!"}')

BODY=$(echo "$RESPONSE" | head -n 1)
STATUS=$(echo "$RESPONSE" | tail -n 1)

if [ "$STATUS" -ne 200 ]; then
    echo "❌ Login API returned HTTP $STATUS"
    exit 1
fi

ACCESS_TOKEN=$(echo "$BODY" | jq -r '.access_token')

REFRESH_TOKEN=$(echo "$BODY" | jq -r '.refresh_token')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$REFRESH_TOKEN" ]; then
    echo "❌ Login API did not return access_token"
    exit 1
fi

echo "✅ Login successful!"
echo "Access Token: $ACCESS_TOKEN"
echo "Refresh Token: $ACCESS_TOKEN"
