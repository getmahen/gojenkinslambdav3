node {
  parameters {
        string(name: 'BUILD_ENV', defaultValue: 'dev', description: 'Targeted Environment to build')
    }

    def root = tool name: 'Golang', type: 'go'

    ws("${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${BUILD_ID}/src/github.com/gojenkinslambdav3") {
        withEnv(["GOROOT=${root}", "GOPATH=${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${BUILD_ID}/", "PATH+GO=${root}/bin"]) {
            env.PATH="${GOPATH}/bin:$PATH"
            def packageName = "jenkinsgolambda-${env.BUILD_ID}-`git rev-parse HEAD`"
            //def branchName = getGitBranchName(scm)

            print "DEBUG: Build triggered for ${params.BUILD_ENV} environment..."

            stage('Checkout'){
                    //echo "Checking out SCM from ${branchName}"
                    //checkout scm
                    git url: 'https://github.com/getmahen/gojenkinslambdav3.git'
            }

            stage('Validate'){
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
              //sh "make packageall PACKAGE_NAME=${packageName}"
              
              // sh '''
              //   mkdir -p ${packageName};
              //   cp -r infrastructure ${packageName};
              //   zip ${packageName}.zip jenkinsgolambda
              //   cp ${packageName}.zip ${packageName};
              //   zip -r ${packageName}.zip ${packageName}
              //   rm -rf ${packageName}
              // '''

              sh "mkdir -p ${packageName}"
              sh "cp -r infrastructure ${packageName}"
              sh "zip ${packageName}.zip jenkinsgolambda"
              sh "cp ${packageName}.zip ${packageName}"
              sh "zip -r ${packageName}.zip ${packageName}"
              sh "rm -rf ${packageName}"
            }

            stage('Upload package to AWS S3 testjenkinsartifacts bucket...'){
              //sh 'export AWS_DEFAULT_REGION=us-west-2'
              sh "aws s3 cp ${packageName}.zip s3://testjenkinsartifacts/${packageName}.zip"
            }
        }
    }
}