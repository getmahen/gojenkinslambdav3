
.PHONY: clean
clean:
	@go clean
	rm -rf jenkinsgolambda && rm -rf jenkinsgolambda.zip

.PHONY: test
test:
	@echo "Running unit tests.."
	go test ./... -race -cover -v 2>&1

.PHONY: build
build: clean
	@echo "building..."
	GOOS=linux go build --ldflags "-X main.version=`git rev-parse HEAD`" -o jenkinsgolambda

.PHONY: upload
upload:
	@echo "$(TS_COLOR)$(shell date "+%Y/%m/%d %H:%M:%S")$(NO_COLOR)$(OK_COLOR)==> Deploying Zip to s3$(NO_COLOR)"
	zip jenkinsgolambda.zip jenkinsgolambda
	aws s3 cp jenkinsgolambda.zip s3://testjenkinsartifacts/jenkinsgolambda.zip --metadata GitHash=`git rev-parse HEAD`

.PHONY: package
package: build
	zip -v jenkinsgolambda.zip jenkinsgolambda

 