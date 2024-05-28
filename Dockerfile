FROM golang:1.22.1-alpine AS builder

WORKDIR /builder

COPY ./build ./build
COPY ./main.go ./main.go
COPY ./go.mod ./go.mod

RUN go build -o web-app main.go

FROM alpine 

WORKDIR /web-app

COPY --from=builder /builder/web-app ./

EXPOSE 8080

CMD [ "./web-app" ]
