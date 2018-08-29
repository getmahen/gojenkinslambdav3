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
                checkout scm

                sh 'go version'
            }
        }
  }
    
}