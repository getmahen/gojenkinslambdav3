pipeline {
  agent any

  environment {
    LAMBDA_NAME = "jenkinsgolambda"
    GOROOT = tool name: 'Golang', type: 'go'
    GOPATH = "${env.JENKINS_HOME}/jobs/${env.JOB_NAME}/builds/${env.BUILD_ID}/"
    //PATH = "${GOROOT}/bin"
    PATH = "${GOPATH}/bin:${GOROOT}/bin:${PATH}"
    WORKSPACE = "${env.GOPATH}/src/github.com/gojenkinslambdav3"
  }

  parameters {
        choice(name: 'BUILD_ENV', choices: ['dev', 'qa', 'prod', 'transit', 'master', 'all'], description: 'Choose an environment to build your AMI')
        string(name: 'BUILDER_REGION', defaultValue: 'us-west-2', description: 'Choose which region to build your lambda. (generally, us-east-2 is for application envs, us-east-1 is for master account)')
  }

  stages {
        stage('checkout') {
            steps {
              wrap([$class: 'BuildUser']) {
                dir("${env.WORKSPACE}") {
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

              dir("${env.WORKSPACE}/infrastructure/terraform") {
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
                    echo 'Package validation failed'
                    slackSend channel: '#infra_chatops', color: 'failed', message: "Lambda Package validation FAILED. Job: `${env.JOB_NAME}` (<${env.BUILD_URL}|#${env.BUILD_NUMBER}>)"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
              wrap([$class: 'BuildUser']) {

                dir("${env.WORKSPACE}") {
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
              dir("${env.WORKSPACE}") {
                  sh 'make test'
              }
             }
           }
        }

        stage('Build and Package...'){
          
           steps {
             wrap([$class: 'BuildUser']) {
              dir("${env.WORKSPACE}") {
                  sh "make build"

                  sh "mkdir -p ${packageName}"
                  sh "cp -r infrastructure ${packageName}"
                  sh "zip ${env.LAMBDA_NAME}.zip ${env.LAMBDA_NAME}"
                  sh "cp ${env.LAMBDA_NAME}.zip ${packageName}"
                  sh "zip -r ${packageName}.zip ${packageName}"
              }
            }
           }
           post {
                success {
                    echo 'Build and Package successfull'
                }
                failure {
                    echo 'Build and Package step failed'
                    slackSend channel: '#infra_chatops', color: 'failed', message: "Lambda Build and Package validation FAILED. Job: `${env.JOB_NAME}` (<${env.BUILD_URL}|#${env.BUILD_NUMBER}>)"
                }
                cleanup {
                    echo 'Deleting build artifacts..'
                    sh "rm -rf ${env.WORKSPACE}/${packageName}"
                } 
            }
        }

        stage('Upload package to AWS S3 testjenkinsartifacts bucket...'){
           steps {
             wrap([$class: 'BuildUser']) {
              dir("${env.WORKSPACE}") {
                  sh "aws s3 cp ${packageName}.zip s3://testjenkinsartifacts/${packageName}.zip"
              }
            }
           }

           post {
                success {
                    echo 'Uploaded packed to AWS S3 successfully'
                    slackSend channel: '#infra_chatops', color: 'success', message: "Lambda Package: ${packageName} uploaded to AWS S3 successfully. Job: `${env.JOB_NAME}` (<${env.BUILD_URL}|#${env.BUILD_NUMBER}>)"
                }
                failure {
                    echo 'Package upload to AWS S3 failed'
                    slackSend channel: '#infra_chatops', color: 'failed', message: "Lambda Package: ${packageName} upload to AWS S3 FAILED. Job: `${env.JOB_NAME}` (<${env.BUILD_URL}|#${env.BUILD_NUMBER}>)"
                }
                cleanup {
                    echo 'Deleting build artifacts..'
                    sh "rm -rf ${env.WORKSPACE}/${packageName}.zip"
                    sh "rm -rf ${env.WORKSPACE}/${env.LAMBDA_NAME}.zip"
                    sh "rm -rf ${env.WORKSPACE}/${env.LAMBDA_NAME}"
                } 
            }
        }

        //Trigger Lambda deployment based on certain conditions (see `when` clause below) 
        //such as Environment  or Branch this build is triggered by
        stage('Trigger Lambda Deployment job'){
          when {
              //expression { params.BUILD_ENV == 'dev' }

              anyOf {
                  branch 'dev'
                  equals expected: 'dev', actual: params.BUILD_ENV
              }
          }

           steps {
             wrap([$class: 'BuildUser']) {
                dir("${env.WORKSPACE}") {

                  build job: 'TestDeployLamda', propagate: false, wait: false,
                    parameters: [
                    string(name: 'ARTIFACT_VERSION', value: "${artifactVersion}"), 
                    string(name: 'REGION', value: "${params.BUILDER_REGION}"), 
                    string(name: 'DEPLOY_ENV', value: "${params.BUILD_ENV}"), 
                    string(name: 'VAULT_TOKEN', value: '34324788-2378y4'), 
                    string(name: 'ANSIBLE_VAULT_ID', value: 'jhsdgfjhgj'), 
                    string(name: 'LAMBDA_NAME', value: "${env.LAMBDA_NAME}")]
                }
              }
           }
        }

  }
    
}