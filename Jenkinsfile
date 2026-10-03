pipeline {
    agent any
    stages {
        stage('Pull') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/vaish8913/simpletravel.git'
            }
        }
        stage('terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('terraform validate') {
            steps {
                sh 'terraform validate'
            }
        }
        stage('terraform plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }
        stage('terraform apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
