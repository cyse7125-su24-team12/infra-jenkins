pipeline {
    agent any  // This specifies that the pipeline can run on any available agent

    stages {
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
        always {
            echo 'The Terraform validation process is completed.'
        }
    }
}
