package handler

import (
	"errors"
	"net/http"
	"os"

	"github.com/rs/zerolog"
)

var httpClient *http.Client

var lambdaName string

var config = &struct {
	VaultURL string `consul:"vault/url"`
}{}

func stringToLogLevel(logLevel string) (zerolog.Level, error) {
	switch logLevel {
	case "DEBUG":
		return zerolog.DebugLevel, nil
	case "INFO":
		return zerolog.InfoLevel, nil
	case "WARN":
		return zerolog.WarnLevel, nil
	case "ERROR":
		return zerolog.ErrorLevel, nil
	case "FATAL":
		return zerolog.FatalLevel, nil
	case "PANIC":
		return zerolog.PanicLevel, nil
	case "DISABLED":
		return zerolog.Disabled, nil
	default:
		return zerolog.DebugLevel, errors.New("Invalid log level")
	}
}

// initialize - put things in here that don't need to be set on every invocation
func initialize() error {

	lambdaName = os.Getenv("AWS_LAMBDA_FUNCTION_NAME")
	zerolog.TimestampFieldName = "timestamp"
	logger = zerolog.New(os.Stdout).With().
		Timestamp().
		Str("lambdaName", lambdaName).
		Str("environment", os.Getenv("ENVIRONMENT")).
		Str("version", version).
		Logger()

	levelStr := os.Getenv("LOG_LEVEL")
	if levelStr == "" {
		levelStr = "DEBUG"
	}
	level, err := stringToLogLevel(levelStr)

	if err != nil {
		zerolog.SetGlobalLevel(zerolog.DebugLevel)
		logger.Error().
			Str("input", levelStr).
			Msg("Invalid logging level specified - logging at debug level")
	} else {
		zerolog.SetGlobalLevel(level)
	}
	logger.Debug().Msg("Initializing lambda...")

	return nil
}
