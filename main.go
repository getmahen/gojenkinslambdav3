package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/gojenkinslambdav3/handler"
)

var version string

func main() {
	lambda.Start(handler.HandleApiGatewayRequest)
}
