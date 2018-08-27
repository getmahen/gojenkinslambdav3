# jenkinsgolambda

This is a POC to build Go based Lambda repository using Jenkinsfile that defines the build pipeline steps.

# ABOUT THE **build** Pipeline
* The Jenkinsfile in this repo defines pipeline steps to checkout source code from SCM, build, run unit tests, package
* the artifact (with version tagging) and then uploads it into a configured Jenkins S3 bucket which acts as a build artifact repository
