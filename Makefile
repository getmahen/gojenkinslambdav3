
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
	zip jenkinsgolambda.zip jenkinsgolambda

.PHONY: upload
upload:
	@echo "$(TS_COLOR)$(shell date "+%Y/%m/%d %H:%M:%S")$(NO_COLOR)$(OK_COLOR)==> Deploying Zip to s3$(NO_COLOR)"
	aws s3 cp jenkinsgolambda.zip s3://testjenkinsartifacts/jenkinsgolambda.zip --metadata GitHash=`git rev-parse HEAD`

.PHONY: package
package: build
	cd checkipaddress && zip -v checkipaddress.zip checkipaddress

.PHONY: packageall
packageall: build
	mkdir -p $(PACKAGE_NAME);
	cp -r infrastructure $(PACKAGE_NAME);
	cp checkipaddress/checkipaddress $(PACKAGE_NAME);
	zip -r $(PACKAGE_NAME).zip $(PACKAGE_NAME)
	rm -rf $(PACKAGE_NAME)

.PHONY: packagealltest
packagealltest: build
	mkdir -p $(PACKAGE_NAME);
	cp -r infrastructure $(PACKAGE_NAME);
	zip checkipaddress.zip checkipaddress/checkipaddress
	cp checkipaddress.zip $(PACKAGE_NAME);
	zip -r $(PACKAGE_NAME).zip $(PACKAGE_NAME)
	rm -rf $(PACKAGE_NAME)

.PHONY: upload
upload: package
	@echo "$(TS_COLOR)$(shell date "+%Y/%m/%d %H:%M:%S")$(NO_COLOR)$(OK_COLOR)==> Deploying Zip to s3$(NO_COLOR)"
	ls -la
	cd checkipaddress
	aws s3 cp ./checkipaddress/checkipaddress.zip s3://testjenkinsartifacts/checkipaddress.zip --metadata GitHash=`git rev-parse HEAD`

 