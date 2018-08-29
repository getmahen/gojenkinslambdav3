pipeline {
  agent any

  stages {
        stage('checkout') {
            steps {
               tool name: 'Golang', type: 'go'
                //git url: 'https://github.com/getmahen/gojenkinslambda3.git'
                checkout scm

                sh 'go version'
            }
        }
  }
    
}