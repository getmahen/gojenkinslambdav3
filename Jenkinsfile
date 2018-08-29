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
              wrap([$class: 'BuildUser']) {
                dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {
                  checkout scm
                }
              }
            }
        }

        stage('Validate') {
          steps {
            wrap([$class: 'BuildUser']) {
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

          post {
                success {
                    echo 'Package validation passed'
                }
                failure {
                    slackSend channel: '#infra_chatops', color: 'failed', message: "Lambda Package validation FAILED. Job: `${env.JOB_NAME}` (<${env.BUILD_URL}|#${env.BUILD_NUMBER}>)"
                    echo 'Package validation failed'
                }
            }
        }

        stage('Install Dependencies') {
            steps {
              wrap([$class: 'BuildUser']) {

                dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {
                  sh 'go version'
                  sh 'go get -u github.com/golang/dep/...'
                  sh 'dep ensure -v'
                }
              }
            }
        }

        stage('Run Unit tests...'){
           steps {
             wrap([$class: 'BuildUser']) {
              dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {
                  sh 'make test'
              }
             }
           }
        }

        stage('Build and Package...'){
           steps {
             wrap([$class: 'BuildUser']) {
              dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {
                  sh "make build"

                  sh "mkdir -p ${packageName}"
                  sh "cp -r infrastructure ${packageName}"
                  sh "zip ${env.LAMBDA_NAME}.zip ${env.LAMBDA_NAME}"
                  sh "cp ${env.LAMBDA_NAME}.zip ${packageName}"
                  sh "zip -r ${packageName}.zip ${packageName}"
                  //sh "rm -rf ${packageName}"
              }
            }
           }
           post {
                success {
                    echo 'Build and Package successfull'
                }
                failure {
                    slackSend channel: '#infra_chatops', color: 'failed', message: "Lambda Build and Package validation FAILED. Job: `${env.JOB_NAME}` (<${env.BUILD_URL}|#${env.BUILD_NUMBER}>)"
                    echo 'Build and Package step failed'
                }
                cleanup {
                    echo 'Deleting build artifacts..'
                    sh "rm -rf ${packageName}"
                } 
            }
        }

        stage('Upload package to AWS S3 testjenkinsartifacts bucket...'){
           steps {
             wrap([$class: 'BuildUser']) {
              dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {
                  sh "aws s3 cp ${packageName}.zip s3://testjenkinsartifacts/${packageName}.zip"
                  sh "rm -rf ${packageName}.zip"
                  sh "rm -rf ${env.LAMBDA_NAME}.zip"
                  sh "rm -rf ${env.LAMBDA_NAME}"
              }
            }
           }
        }


        stage('Trigger Lambda Deployment job'){
           steps {
             wrap([$class: 'BuildUser']) {
                dir("${env.GOPATH}/src/github.com/gojenkinslambdav3") {

                  build job: 'TestDeployLamda', propagate: false, wait: false,
                    parameters: [
                    string(name: 'ARTIFACT_VERSION', value: "${artifactVersion}"), 
                    string(name: 'REGION', value: 'us-west-2'), 
                    string(name: 'DEPLOY_ENV', value: 'dev'), 
                    string(name: 'VAULT_TOKEN', value: '34324788-2378y4'), 
                    string(name: 'ANSIBLE_VAULT_ID', value: 'jhsdgfjhgj'), 
                    string(name: 'LAMBDA_NAME', value: "${env.LAMBDA_NAME}")]
                }
              }
           }
        }

  }
    
}