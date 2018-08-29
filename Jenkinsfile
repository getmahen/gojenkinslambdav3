pipeline {
  agent any

  wrappers {
        golang('Go 1.10')
    }

  stages {
        stage('checkout') {
            steps {
                git url: 'https://github.com/getmahen/gojenkinslambda3.git'

                sh 'go version'
            }
        }
  }
    
}