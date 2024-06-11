pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']],
                    extensions: [[$class: 'CleanCheckout']],
                    userRemoteConfigs: [[url: "https://github.com/cyse7125-su24-team12/infra-jenkins.git", credentialsId: 'git-credentials-id']]
                ])
            }
        }

        stage('Verify Terraform Format') {
            steps {
                script {
                    sh 'terraform fmt -check .'
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }

        stage('Check Terraform Syntax') {
            steps {
                script {
                    sh 'terraform validate'
                }
            }
        }
    }

    post {
        success {
            echo 'The Terraform validation process is completed successfully.'
        }
        failure {
            echo 'The Terraform validation process is failed.'
        }
    }
}
