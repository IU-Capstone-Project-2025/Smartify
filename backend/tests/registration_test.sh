#!/bin/bash
set -e

#Hi

echo "Running registration test..."

RESPONSE=$(curl -s -X POST http://localhost:8080/api/registration_emailvalidation \
     -H "Content-Type: application/json" \
     -d '{"email":"test@mail.com"}')

BODY=$(echo "$RESPONSE" | head -n -1)
STATUS=$(echo "$RESPONSE" | tail -n1)

CODE_VALUE=$(echo "$STATUS" | jq -r '.code')

if [ "$CODE_VALUE" -ne 200 ]; then
  echo "❌ Registration emailvalidation failed: HTTP $STATUS"
  echo "$BODY"
  exit 1
fi

echo "✅ Email validation request succeeded"

MAILHOG_CODE=""
for i in {1..10}; do
    echo "Attempt $i to get code from MailHog..."
    MAILHOG_FULL_RESPONSE=$(curl -s http://localhost:8025/api/v2/messages)

    RECEIVED_CODE=$(echo "$MAILHOG_FULL_RESPONSE" | jq -r '.items[0].Content.Body' 2>/dev/null)

    if [ -n "$RECEIVED_CODE" ]; then
        MAILHOG_CODE="$RECEIVED_CODE"
        echo "✅ MailHog code found: $MAILHOG_CODE"
        break
    fi
    sleep 2
done

if [ -z "$MAILHOG_CODE" ]; then
    echo "❌ No code found in Mailhog email after multiple attempts."
    echo "MailHog Raw Response: $MAILHOG_FULL_RESPONSE"
    exit 1
fi


RESPONSE=$(curl -s -X POST http://localhost:8080/api/registration_codevalidation \
     -H "Content-Type: application/json" \
     -d '{"email":"test@mail.com","code":"'"$MAIL_CODE"'"}')

BODY=$(echo "$RESPONSE" | head -n -1)
CODE_VALUE=$(echo "$STATUS" | jq -r '.code')

if [ "$CODE_VALUE" -ne 200 ]; then
  echo "❌ Registration codevalidation failed: HTTP $STATUS"
  echo "$BODY"
  exit 1
fi

echo "✅ Email codevalidation request succeeded"

RESPONSE=$(curl -s -X POST http://localhost:8080/api/registration_password \
     -H "Content-Type: application/json" \
     -d '{"email":"test@mail.com","password":"Loh1725!"}')

BODY=$(echo "$RESPONSE" | head -n -1)
CODE_VALUE=$(echo "$STATUS" | jq -r '.code')

if [ "$CODE_VALUE" -ne 200 ]; then
  echo "❌ Registration registration_password failed: HTTP $STATUS"
  echo "$BODY"
  exit 1
fi

echo "✅ Email registration_password request succeeded"


