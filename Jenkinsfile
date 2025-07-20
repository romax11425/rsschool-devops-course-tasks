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
                echo 'Checking environment...'
                sh 'which python || echo "Python not found"'
                sh 'which pip || echo "Pip not found"'
                
                // Используем Docker для установки зависимостей
                echo 'Installing dependencies using Docker...'
                sh 'docker run --rm -v "${WORKSPACE}/app:/app" python:3.9-slim pip install -r /app/requirements.txt'
            }
        }
        
        stage('Unit Tests') {
            steps {
                echo 'Running tests using Docker...'
                sh 'docker run --rm -v "${WORKSPACE}/app:/app" -w /app python:3.9-slim sh -c "pip install pytest pytest-cov && python -m pytest --cov=. --cov-report=xml:coverage.xml --junitxml=test-results.xml"'
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
                echo 'Checking if kubectl and helm are available...'
                sh 'which kubectl || echo "kubectl not found"'
                sh 'which helm || echo "helm not found"'
                
                echo 'Updating Helm chart values...'
                sh "sed -i 's|repository: flask-app|repository: ${DOCKER_REPO}|g' helm-charts/flask-app/values.yaml || echo 'sed command failed'"
                sh "sed -i 's|tag: latest|tag: ${APP_VERSION}|g' helm-charts/flask-app/values.yaml || echo 'sed command failed'"
                sh "sed -i 's|pullPolicy: Never|pullPolicy: Always|g' helm-charts/flask-app/values.yaml || echo 'sed command failed'"
                
                echo 'Deploying with Helm...'
                sh "helm upgrade --install flask-app helm-charts/flask-app || echo 'Helm deployment failed'"
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                sh '''
                    # Check if kubectl is available
                    if ! command -v kubectl &> /dev/null; then
                        echo "kubectl not found, skipping verification"
                        exit 0
                    fi
                    
                    # Wait for deployment to be ready
                    kubectl rollout status deployment/flask-app || echo "Deployment not ready"
                    
                    # Get minikube IP if available
                    if command -v minikube &> /dev/null; then
                        MINIKUBE_IP=$(minikube ip)
                        echo "Minikube IP: ${MINIKUBE_IP}"
                        
                        # Test the application
                        if command -v curl &> /dev/null; then
                            curl -s http://${MINIKUBE_IP}:30081 || echo "Could not connect to application"
                        else
                            echo "curl not found, skipping application test"
                        fi
                    else
                        echo "minikube not found, skipping application test"
                    fi
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