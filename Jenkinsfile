node {
  parameters {
        string(name: 'BUILD_ENV', defaultValue: 'dev', description: 'Targeted Environment to build')
    }

    def root = tool name: 'Golang', type: 'go'

    ws("${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${BUILD_ID}/src/github.com/gojenkinslambdav3") {
        withEnv(["GOROOT=${root}", "GOPATH=${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${BUILD_ID}/", "PATH+GO=${root}/bin"]) {
            env.PATH="${GOPATH}/bin:$PATH"

            def lambdaName = "jenkinsgolambda"
            def artifactVersion
            def packageName

            stage('Checkout'){
                checkout scm
            }

            stage('Validate'){
                    def gitHash = sh returnStdout: true, script: 'git rev-parse HEAD'
                    artifactVersion = "${env.BUILD_ID}-${gitHash}".trim()
                    packageName = "${lambdaName}-${artifactVersion}"

                    print "DEBUG: PACKAGE NAME: ${packageName}"

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
              sh "zip ${lambdaName}.zip ${lambdaName}"
              sh "cp ${lambdaName}.zip ${packageName}"
              sh "zip -r ${packageName}.zip ${packageName}"
              sh "rm -rf ${packageName}"
            }

            stage('Upload package to AWS S3 testjenkinsartifacts bucket...'){
              sh "aws s3 cp ${packageName}.zip s3://testjenkinsartifacts/${packageName}.zip"
              sh "rm -rf ${packageName}.zip"
              sh "rm -rf ${lambdaName}.zip"
              sh "rm -rf ${lambdaName}"
            }

            // This Stage can be conditionally executed based on the Branch
            //if ("${params.BUILD_ENV}" == 'dev') {

              stage('Trigger Lambda Deployment job') {
                
                build job: 'TestDeployLamda', propagate: false, wait: false,
                parameters: [
                string(name: 'ARTIFACT_VERSION', value: "${artifactVersion}"), 
                string(name: 'REGION', value: 'us-west-2'), 
                string(name: 'DEPLOY_ENV', value: 'dev'), 
                string(name: 'VAULT_TOKEN', value: '34324788-2378y4'), 
                string(name: 'ANSIBLE_VAULT_ID', value: 'jhsdgfjhgj'), 
                string(name: 'LAMBDA_NAME', value: "${lambdaName}")]

              }
            //}
        }
    }
}