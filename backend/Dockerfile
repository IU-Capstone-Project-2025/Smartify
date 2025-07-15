FROM golang:1.24 as builder
WORKDIR /app
COPY . .

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./app/main.go

# Шаг 2: Запускаем
FROM alpine:latest

WORKDIR /app
COPY --from=builder /app/main .
COPY --from=builder /app/app/api ./app/api
COPY --from=builder /app/app/docs ./app/docs

EXPOSE 8080
CMD ["./main"]