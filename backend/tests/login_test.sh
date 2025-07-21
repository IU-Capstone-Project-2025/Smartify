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




RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST http://localhost:8080/api/refresh_token \
  -H "Content-Type: application/json" \
  -d "{\"refresh_token\":\"$REFRESH_TOKEN\"}")


BODY=$(echo "$RESPONSE" | head -n 1)
STATUS=$(echo "$RESPONSE" | tail -n 1)

if [ "$STATUS" -ne 200 ]; then
    echo "❌ Refresh API returned HTTP $STATUS"
    exit 1
fi

ACCESS_TOKEN=$(echo "$BODY" | jq -r '.access_token')

REFRESH_TOKEN=$(echo "$BODY" | jq -r '.refresh_token')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$REFRESH_TOKEN" ]; then
    echo "❌ Login API did not return access_token"
    exit 1
fi

echo "✅ Refresh successful!"
echo "Access Token: $ACCESS_TOKEN"
echo "Refresh Token: $ACCESS_TOKEN"


QUESTIONNAIRE_RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -H "Access_token: $ACCESS_TOKEN" \
  -d '{"user_id":0,"class":"11 класс","region":"Москва/Московская обл.","avg_grade":"4.6–5.0","favorite_subjects":["Математика","Информатика","Биология"],"hard_subjects":["Математика","Информатика"],"subject_scores":{"Математика":1,"Русский язык":1,"Химия":1,"Биология":1,"Физика":1,"Информатика":1,"История":1},"interests":["Помогать людям","Разрабатывать технологии","Делать эксперименты и исследования"],"values":["Высокий доход","Стабильность"],"mbti_scores":{"q11":1,"q12":1,"q13":1,"q14":1,"q15":1,"q16":1,"q17":1,"q18":1,"q19":1,"q20":1,"q21":1,"q22":1,"q23":1,"q24":1,"q25":1,"q26":1,"q27":1,"q28":1,"q29":1,"q30":1,"q31":1,"q32":1,"q33":1,"q34":1,"q35":1},"work_preferences":{"role":"Исследователем и стратегом","place":"В лаборатории","style":"Спонтанно, в зависимости от ситуации","exclude":"Постоянно общаться"}}')

QUESTIONNAIRE_BODY=$(echo "$QUESTIONNAIRE_RESPONSE" | head -n 1)
QUESTIONNAIRE_STATUS=$(echo "$QUESTIONNAIRE_RESPONSE" | tail -n 1)

if [ "$QUESTIONNAIRE_STATUS" -ne 200 ]; then
    echo "❌ Questionnaire API returned HTTP $QUESTIONNAIRE_STATUS"
    echo "Response: $QUESTIONNAIRE_BODY"
    exit 1
fi

count=$(echo "QUESTIONNAIRE_BODY" | jq 'length')

# Проверка
if [ "$count" -eq 5 ]; then
  echo "✅ Test passed: returned $count professions"
  exit 0
else
  echo "❌ Test failed: expected 5 professions, got $count"
  exit 1
fi

