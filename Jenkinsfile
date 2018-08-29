pipeline {
  agent any

  environment {
    LAMBDA_NAME = "jenkinsgolambda"
    GOROOT = tool name: 'Golang', type: 'go'
    GOPATH = "${env.JENKINS_HOME}/jobs/${env.JOB_NAME}/builds/${env.BUILD_ID}/"
    //PATH = "${GOROOT}/bin"
    PATH = "${GOPATH}/bin:${GOROOT}/bin:${PATH}"
  }

  stages {
        stage('checkout') {
            steps {
              dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {
                checkout scm
              }
            }
        }

        stage('Validate') {
          steps {
            gitHash = sh returnStdout: true, script: 'git rev-parse HEAD'
            artifactVersion = "${env.BUILD_ID}-${gitHash}".trim()
            packageName = "${env.LAMBDA_NAME}-${artifactVersion}"

            dir("${env.GOPATH}/src/github.com/gojenkinslambdav3/infrastructure/terraform") {
              sh 'terraform init -backend=false'
              sh 'terraform validate'
            }
          }
        }

        stage('Install Dependencies') {
            steps {
              echo "GITHASH==${gitHash}"
              echo "artifactVersion==${artifactVersion}"
              echo "packageName==${packageName}"

              dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {
                sh 'go version'
                sh 'go get -u github.com/golang/dep/...'
                sh 'dep ensure -v'
              }
            }
        }

        stage('Run Unit tests...'){
           steps {
             dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {
                sh 'make test'
             }
           }
        }
  }
    
}