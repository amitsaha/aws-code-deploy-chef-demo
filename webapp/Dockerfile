FROM golang:1.12-alpine3.9
RUN mkdir /app
ADD . /app
WORKDIR /app

RUN go build -o server main.go
EXPOSE 8080
ENTRYPOINT /app/server