// Jenkins pipeline: test -> build -> deploy to the idle slot -> human approval -> switch -> smoke test
pipeline {
    agent any

    environment {
        VERSION = "v${env.BUILD_NUMBER}"   // build #7 becomes version v7
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Test') {
            steps {
                sh 'docker build -t devops-app:test ./app'
                sh 'docker run --rm devops-app:test pytest -q -p no:cacheprovider'
            }
        }

        stage('Deploy to idle slot') {
            steps {
                sh 'chmod +x scripts/*.sh'
                sh './scripts/deploy-idle.sh $VERSION'
            }
        }

        stage('Approve switch') {
            steps {
                input message: "Version ${env.VERSION} is healthy on the idle slot. Switch live traffic to it?"
            }
        }

        stage('Switch traffic') {
            steps {
                script {
                    def active = sh(script: './scripts/active-color.sh', returnStdout: true).trim()
                    def idle = (active == 'blue') ? 'green' : 'blue'
                    sh "./scripts/switch.sh ${idle}"
                }
            }
        }

        stage('Smoke test') {
            steps {
                sh 'docker exec proxy wget -qO- http://localhost/api'
            }
        }
    }

    post {
        success { echo "Deployed ${env.VERSION} with Blue/Green" }
        failure { echo 'Pipeline failed - live traffic was NOT switched. Run ./scripts/rollback.sh if needed.' }
    }
}
