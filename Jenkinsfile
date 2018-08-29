pipeline {
  agent any

  environment {
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

        stage('Install Dependencies') {
            steps {
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