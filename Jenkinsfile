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
            script {
              gitHash = sh returnStdout: true, script: 'git rev-parse HEAD'
              artifactVersion = "${env.BUILD_ID}-${gitHash}".trim()
              packageName = "${env.LAMBDA_NAME}-${artifactVersion}"
            }

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

        stage('Build and Package...'){
           steps {
             dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {
                sh "make build"

                sh "mkdir -p ${packageName}"
                sh "cp -r infrastructure ${packageName}"
                sh "zip ${lambdaName}.zip ${lambdaName}"
                sh "cp ${lambdaName}.zip ${packageName}"
                sh "zip -r ${packageName}.zip ${packageName}"
                sh "rm -rf ${packageName}"
             }
           }
        }

        stage('Upload package to AWS S3 testjenkinsartifacts bucket...'){
           steps {
             dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {
                sh "aws s3 cp ${packageName}.zip s3://testjenkinsartifacts/${packageName}.zip"
                sh "rm -rf ${packageName}.zip"
                sh "rm -rf ${lambdaName}.zip"
                sh "rm -rf ${lambdaName}"
             }
           }
        }


        stage('Trigger Lambda Deployment job'){
           steps {
             dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {
               
               build job: 'TestDeployLamda', propagate: false, wait: false,
                parameters: [
                string(name: 'ARTIFACT_VERSION', value: "${artifactVersion}"), 
                string(name: 'REGION', value: 'us-west-2'), 
                string(name: 'DEPLOY_ENV', value: 'dev'), 
                string(name: 'VAULT_TOKEN', value: '34324788-2378y4'), 
                string(name: 'ANSIBLE_VAULT_ID', value: 'jhsdgfjhgj'), 
                string(name: 'LAMBDA_NAME', value: "${lambdaName}")]
             }
           }
        }

  }
    
}