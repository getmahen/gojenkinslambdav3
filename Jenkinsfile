node {
  parameters {
        string(name: 'BUILD_ENV', defaultValue: 'dev', description: 'Targeted Environment to build')
    }

    def root = tool name: 'Golang', type: 'go'

    ws("${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${BUILD_ID}/src/github.com/gojenkinslambdav3") {
        withEnv(["GOROOT=${root}", "GOPATH=${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${BUILD_ID}/", "PATH+GO=${root}/bin"]) {
            env.PATH="${GOPATH}/bin:$PATH"

            // def gitHash = "`git rev-parse HEAD`"
            // def lambdaName = "jenkinsgolambda"
            // def artifactVersion = "${env.BUILD_ID}-${gitHash}"
            // def packageName = "${lambdaName}-${artifactVersion}"

            
            def lambdaName = "jenkinsgolambda"
            //def gitHash
            def artifactVersion
            def packageName

            
            //print "DEBUG: PACKAGE NAME: ${packageName}"

            stage('Checkout'){
                    checkout scm
            }

            stage('Validate'){
                    def gitHash_1 = sh returnStdout: true, script: 'git rev-parse HEAD'
                    artifactVersion = "${env.BUILD_ID}-${gitHash_1}".trim()
                    packageName = "${lambdaName}-${artifactVersion}"

                    echo 'Validating terraform...'
                    dir('infrastructure/terraform') {
                      sh 'terraform init -backend=false'
                      sh 'terraform validate'
                    }
            }

            stage('Install Dependencies'){
              sh 'go version'
              sh 'go get -u github.com/golang/dep/...'
              sh 'dep ensure -v'
            }

             stage('Run Unit tests...'){
              sh 'make test'
            }

            stage('Build and Package...'){
              sh "make build"

              sh "mkdir -p ${packageName}"
              sh "cp -r infrastructure ${packageName}"
             //sh "zip ${packageName}.zip jenkinsgolambda"
              sh "zip ${lambdaName}.zip ${lambdaName}"
              sh "cp ${lambdaName}.zip ${packageName}"
              sh "zip -r ${packageName}.zip ${packageName}"
              sh "rm -rf ${packageName}"
            }

            stage('Upload package to AWS S3 testjenkinsartifacts bucket...'){
              sh "aws s3 cp ${packageName}.zip s3://testjenkinsartifacts/${packageName}.zip"
              sh "rm -rf ${packageName}.zip"
            }

            stage('Trigger Lambda Deployment job') {
              def hash = sh returnStdout: true, script: 'git rev-parse HEAD'
              def version = "${env.BUILD_ID}-${hash}".trim()

              build job: 'TestDeployLamda', propagate: false, wait: false,
              parameters: [
              string(name: 'ARTIFACT_VERSION', value: "${version}"), 
              string(name: 'REGION', value: 'us-west-2'), 
              string(name: 'DEPLOY_ENV', value: 'dev'), 
              string(name: 'VAULT_TOKEN', value: '34324788-2378y4'), 
              string(name: 'ANSIBLE_VAULT_ID', value: 'jhsdgfjhgj'), 
              string(name: 'LAMBDA_NAME', value: "${lambdaName}")]

            }
        }
    }
}