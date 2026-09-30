pipeline {
    agent any 
    stages {
        stage('Pull') { 
            steps {
                git 'https://github.com/nivas-22/Jenkins-Terra.git'
            }
        }
        stage('terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('terraform plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('terraform validate') {
            steps {
                sh 'terraform validate'
            }
        }
        stage('terraform apply') {
            steps {
                sh 'terraform ${Action} --auto-approve'
            }
        }
    }
}
