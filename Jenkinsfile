pipeline {
    agent any

    environment {
        IMAGE_NAME     = "countrytourism"
        IMAGE_TAG      = "v1"
        CONTAINER_NAME = "countrytourism"
    }

    triggers {
        pollSCM('H/5 * * * *')   // or use githubPush() with a webhook configured
    }

    stages {

        stage('Clone Repository') {
            steps {
                sh '''
                    rm -rf simpletravel
                    git clone https://github.com/vaish8913/simpletravel.git
                '''
            }
        }

        stage('Remove Old Container') {
            steps {
                sh 'docker rm -f ${CONTAINER_NAME} || true'
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      -p 7080:80 \
                      ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Check Container') {
            steps {
                sh 'docker ps'
            }
        }
    }

    post {
        success {
            echo 'Deployed successfully.'
        }
        failure {
            echo 'Pipeline failed or was skipped (no index.html change).'
        }
    }
}
