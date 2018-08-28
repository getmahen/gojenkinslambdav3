pipeline {
  agent any

    def root = tool name: 'Golang', type: 'go'

    ws("${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${BUILD_ID}/src/github.com/gojenkinslambdav3") {
        withEnv(["GOROOT=${root}", "GOPATH=${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${BUILD_ID}/", "PATH+GO=${root}/bin"]) {
          env.PATH="${GOPATH}/bin:$PATH"
          def lambdaName = "jenkinsgolambda"
          def packageName = "${lambdaName}-${env.BUILD_ID}-`git rev-parse HEAD`"
          
          print "DEBUG: PACKAGE NAME: ${packageName}"

          stages {
    
            stage('Checkout'){
              steps {
                sh 'Checking out source code from SCM'
                  checkout scm
              }
            }
          }

        }
    }
    
}