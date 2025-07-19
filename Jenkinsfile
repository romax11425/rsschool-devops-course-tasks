pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_REPO = 'flask-app'  // Используем локальный образ без публикации
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        APP_VERSION = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                dir('app') {
                    sh 'pip install -r requirements.txt'
                }
            }
        }
        
        stage('Unit Tests') {
            steps {
                dir('app') {
                    sh 'python -m pytest --cov=. --cov-report=xml:coverage.xml --junitxml=test-results.xml'
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'app/test-results.xml'
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                echo "Skipping SonarQube analysis for local testing"
                // Для реального использования раскомментируйте код ниже и настройте SonarQube
                /*
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner'
                }
                */
            }
        }
        
        stage('Build Docker Image') {
            steps {
                dir('app') {
                    script {
                        docker.build("${DOCKER_REPO}:${APP_VERSION}")
                    }
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                echo "Skipping Docker image push for local testing"
                // Для реального использования раскомментируйте код ниже и настройте Docker Hub credentials
                /*
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", DOCKER_CREDENTIALS_ID) {
                        docker.image("${DOCKER_REPO}:${APP_VERSION}").push()
                        docker.image("${DOCKER_REPO}:${APP_VERSION}").push('latest')
                    }
                }
                */
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                sh "sed -i 's|repository: flask-app|repository: ${DOCKER_REPO}|g' helm-charts/flask-app/values.yaml"
                sh "sed -i 's|tag: latest|tag: ${APP_VERSION}|g' helm-charts/flask-app/values.yaml"
                sh "sed -i 's|pullPolicy: Never|pullPolicy: Always|g' helm-charts/flask-app/values.yaml"
                
                sh "helm upgrade --install flask-app helm-charts/flask-app"
            }
        }
        
        stage('Verify Deployment') {
            steps {
                sh '''
                    # Wait for deployment to be ready
                    kubectl rollout status deployment/flask-app
                    
                    # Get minikube IP
                    MINIKUBE_IP=$(minikube ip)
                    
                    # Test the application
                    curl -s http://${MINIKUBE_IP}:30081 | grep "Hello, World!"
                '''
            }
        }
    }
    
    post {
        success {
            echo "Pipeline succeeded!"
            // Для реального использования Slack раскомментируйте код ниже
            /*
            slackSend(
                color: 'good',
                message: "Pipeline succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            )
            */
        }
        failure {
            echo "Pipeline failed!"
            // Для реального использования Slack раскомментируйте код ниже
            /*
            slackSend(
                color: 'danger',
                message: "Pipeline failed: ${env.JOB_NAME} #${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            )
            */
        }
        always {
            cleanWs()
        }
    }
}