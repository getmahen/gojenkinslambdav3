pipeline {
  agent any

  environment {
    GOROOT = tool name: 'Golang', type: 'go'
    GOPATH = "${env.JENKINS_HOME}/jobs/${env.JOB_NAME}/builds/${env.BUILD_ID}/"
    PATH+GO= "${GOROOT}/bin"
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