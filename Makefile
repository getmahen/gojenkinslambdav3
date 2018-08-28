
BIN_DIR := $(GOPATH)/bin
DEP := $(BIN_DIR)
PACKAGE_NAME := $(PACKAGE_NAME)

# $(DEP):
# 	@echo "Getting DEP"
# 	go get -u github.com/golang/dep/cmd/dep
# 	dep --install &> /dev/null

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

.PHONY: packageall
packagealltest: build
	mkdir -p $(PACKAGE_NAME);
	cp -r infrastructure $(PACKAGE_NAME);
	zip jenkinsgolambda.zip jenkinsgolambda
	cp jenkinsgolambda.zip $(PACKAGE_NAME);
	zip -r $(PACKAGE_NAME).zip $(PACKAGE_NAME)
	rm -rf $(PACKAGE_NAME)

.PHONY: upload
upload: package
	@echo "$(TS_COLOR)$(shell date "+%Y/%m/%d %H:%M:%S")$(NO_COLOR)$(OK_COLOR)==> Deploying Zip to s3$(NO_COLOR)"
	aws s3 cp jenkinsgolambda.zip s3://testjenkinsartifacts/jenkinsgolambda.zip --metadata GitHash=`git rev-parse HEAD`

 