pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Build DEV Image') {
            steps {
                sh '''
                    docker build \
                        -t simpletravel:dev \
                        .
                '''
            }
        }

        stage('Stop Old DEV Container') {
            steps {
                sh '''
                    docker rm -f simpletravel-dev || true
                '''
            }
        }

        stage('Deploy DEV') {
            steps {
                sh '''
                    docker run -d \
                        --name simpletravel-dev \
                        -p 7081:80 \
                        simpletravel:dev
                '''
            }
        }

        stage('Verify DEV') {
            steps {
                sh '''
                    docker ps
                    docker inspect simpletravel-dev
                '''
            }
        }
    }

    post {
        success {
            echo 'DEV deployment successful!'
            echo 'Application: http://YOUR_SERVER:7081'
        }

        failure {
            echo 'DEV deployment failed!'
        }
    }
}
