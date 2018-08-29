pipeline {
  agent any

  stages {
        stage('checkout') {
            steps {
               tool name: 'Golang', type: 'go'
                git url: 'https://github.com/getmahen/gojenkinslambda3.git'

                sh 'go version'
            }
        }
  }
    
}