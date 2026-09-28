pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'prod'],
            description: 'Select deployment environment'
        )
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build \
                            -t simpletravel:${params.ENVIRONMENT} \
                            .
                    """
                }
            }
        }

        stage('Remove Existing Container') {
            steps {
                script {
                    def containerName =
                        params.ENVIRONMENT == 'prod'
                        ? 'simpletravel-prod'
                        : 'simpletravel-dev'

                    sh """
                        docker rm -f ${containerName} || true
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                script {

                    def containerName
                    def port

                    if (params.ENVIRONMENT == 'prod') {
                        containerName = 'simpletravel-prod'
                        port = '7080'
                    } else {
                        containerName = 'simpletravel-dev'
                        port = '7081'
                    }

                    sh """
                        docker run -d \
                            --name ${containerName} \
                            -p ${port}:80 \
                            simpletravel:${params.ENVIRONMENT}
                    """
                }
            }
        }

        stage('Verify') {
            steps {
                sh 'docker ps'
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }

        failure {
            echo "Deployment failed!"
        }
    }
}
