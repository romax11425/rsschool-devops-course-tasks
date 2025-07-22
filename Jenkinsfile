    pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-agent
    version: v1
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:3309.v27b_9314fd1a_4-6
  - name: python
    image: python:3.13.5-slim
    command: ["cat"]
    tty: true
  - name: docker
    image: docker:28
    command: ["cat"]
    tty: true
    volumeMounts:
      - name: docker-sock
        mountPath: /var/run/docker.sock
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
        type: Socket
"""
        }
    }

    triggers {
        pollSCM('H/5 * * * *') // Poll every 5 minutes
    }
    

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials') // ID учетных данных, добавленных в Jenkins
        IMAGE_NAME = 'flask-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        SONAR_TOKEN = credentials('sonarqube-token')
        SONAR_ORGANIZATION = 'rss-devops-course-tasks'
        SONAR_PROJECT_KEY = 'rss-devops-course-tasks_flask-app'
     }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
    stage('Build Application') {
            steps {
                container('python') {
                    sh '''
                        apt-get update && apt-get install -y gcc python3-dev
                        pip install -r app/requirements.txt
                        pip install pytest pytest-cov
                    '''
                }
            }
        }
        
        stage('Unit Tests') {
            steps {
                container('python') {
                    dir('app') {
                        sh 'python -m pytest --cov=. --cov-report=xml:coverage.xml'
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'app/coverage.xml', allowEmptyArchive: true
                }
            }
        }

        stage('Security Check') {
            steps {
                container('python') {
                    sh '''
                        pip install bandit safety
                        mkdir -p reports
                        
                        # Run Bandit security scanner
                        echo "Running Bandit security scan..."
                        cd app && python -m bandit -r . -f txt -o ../reports/bandit-report.txt || true
                        
                        # Run Safety dependency scanner
                        echo "Running Safety dependency scan..."
                        cd app && python -m safety check -r requirements.txt --output text > ../reports/safety-report.txt || true
                    '''

                    // Archive reports
                    archiveArtifacts artifacts: 'reports/*-report.txt', allowEmptyArchive: true
                }
            }
        }

        
        stage('SonarCloud Analysis') {
            steps {
                container('python') {
                    sh 'echo "Starting SonarCloud Analysis stage"'
                    withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                        sh 'echo "Credentials loaded successfully"'
                        sh '''
                            apt-get update -qq && apt-get install -y --no-install-recommends unzip wget openjdk-17-jre-headless
                            # Download and install SonarScanner
                            wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
                            unzip -q sonar-scanner-cli-*.zip
                            # Run SonarCloud scan
                            cd app
                            ../sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner \\
                              -Dsonar.projectKey=${SONAR_PROJECT_KEY} \\
                              -Dsonar.organization=${SONAR_ORGANIZATION} \\
                              -Dsonar.sources=. \\
                              -Dsonar.host.url=https://sonarcloud.io \\
                              -Dsonar.login=${SONAR_TOKEN} \\
                              -Dsonar.python.coverage.reportPaths=coverage.xml
                        '''
                    }
                }
            }
        }
        
        stage('Docker Build and Push') {
            steps {
                container('docker') {
                    dir('app') {
                        sh '''
                            # Login to DockerHub
                            echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                            
                            # Build Docker image
                            docker build -t ${DOCKERHUB_CREDENTIALS_USR}/${IMAGE_NAME}:${IMAGE_TAG} .
                            docker tag ${DOCKERHUB_CREDENTIALS_USR}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_CREDENTIALS_USR}/${IMAGE_NAME}:latest
                            
                            # Push Docker image
                            docker push ${DOCKERHUB_CREDENTIALS_USR}/${IMAGE_NAME}:${IMAGE_TAG}
                            docker push ${DOCKERHUB_CREDENTIALS_USR}/${IMAGE_NAME}:latest
                        '''
                    }
                }
            }
        }


        stage('Install Helm') {
            steps {
                sh '''
                    curl -LO https://get.helm.sh/helm-v3.18.4-linux-amd64.tar.gz
                    tar -zxvf helm-v3.18.4-linux-amd64.tar.gz
                    mv linux-amd64/helm ./helm
                    chmod +x ./helm
                '''
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    # Create namespace if it doesn't exist
                    ./helm upgrade --install flask-app ./app/helm-charts/flask-app \\
                        --create-namespace \\
                        --namespace flask-app \\
                        -f ./app/helm-charts/flask-app/values-minikube.yaml \\
                        --set image.repository=${DOCKERHUB_CREDENTIALS_USR}/${IMAGE_NAME} \\
                        --set image.tag=${IMAGE_TAG} \\
                        --set image.pullPolicy=IfNotPresent \\
                        --timeout=300s
                """
            }
        }
        
        stage('Verify Deployment') {
            steps {
                sh '''
                    # Install kubectl if needed
                    if ! command -v kubectl &> /dev/null; then
                        curl -LO "https://dl.k8s.io/release/stable.txt"
                        KUBECTL_VERSION=$(cat stable.txt)
                        curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
                        chmod +x kubectl
                        mkdir -p $HOME/bin
                        mv kubectl $HOME/bin/
                        export PATH=$HOME/bin:$PATH
                    fi
                    
                    # Check if pods are running
                    echo "\nChecking pod status:"
                    ./helm status flask-app -n flask-app
                    kubectl get pods -n flask-app || echo "Could not get pods"
                    
                    # Kill any existing port-forward processes
                    echo "\nSetting up port forwarding..."
                    pkill -f "port-forward.*flask-app" || echo "No existing port-forward to kill"
                    
                    # Start port forwarding in the background
                    kubectl port-forward svc/flask-app 8080:8080 -n flask-app &
                    PORT_FORWARD_PID=$!
                    
                    # Give it a moment to establish
                    sleep 3
                    
                    # Try to access the service via port-forward
                    echo "\nAttempting to access the service via port-forward..."
                    curl -v http://localhost:8080/ || echo "Service not accessible via port-forward"
                    
                    # Clean up port-forward
                    kill $PORT_FORWARD_PID || echo "Could not kill port-forward process"
                '''
            }
        }
    }
    
    post {
        success {
            echo "Pipeline succeeded!"
            script {
                def discordWebhookUrl = 'https://discord.com/api/webhooks/1396624113656664225/xdlWki9PF65QR1dlnYcNpWNC1ZJnhKIJKK4GWMOOKp3bDzta3uZSts4QKLInI5FAFpZo'
                def payload = """
                {
                    "embeds": [
                        {
                            "title": "Pipeline Succeeded",
                            "description": "${env.JOB_NAME} #${env.BUILD_NUMBER}",
                            "url": "${env.BUILD_URL}",
                            "color": 3066993,
                            "fields": [
                                {
                                    "name": "Status",
                                    "value": "Success",
                                    "inline": true
                                },
                                {
                                    "name": "Build Number",
                                    "value": "${env.BUILD_NUMBER}",
                                    "inline": true
                                }
                            ]
                        }
                    ]
                }
                """
                
                sh "curl -X POST -H 'Content-Type: application/json' -d '${payload}' ${discordWebhookUrl}"
            }
        }
        failure {
            echo "Pipeline failed!"
            script {
                def discordWebhookUrl = 'https://discord.com/api/webhooks/1396624113656664225/xdlWki9PF65QR1dlnYcNpWNC1ZJnhKIJKK4GWMOOKp3bDzta3uZSts4QKLInI5FAFpZo'
                def payload = """
                {
                    "embeds": [
                        {
                            "title": "Pipeline Failed",
                            "description": "${env.JOB_NAME} #${env.BUILD_NUMBER}",
                            "url": "${env.BUILD_URL}",
                            "color": 15158332,
                            "fields": [
                                {
                                    "name": "Status",
                                    "value": "Failure",
                                    "inline": true
                                },
                                {
                                    "name": "Build Number",
                                    "value": "${env.BUILD_NUMBER}",
                                    "inline": true
                                }
                            ]
                        }
                    ]
                }
                """
                
                sh "curl -X POST -H 'Content-Type: application/json' -d '${payload}' ${discordWebhookUrl}"
            }
        }
        always {
            cleanWs()
        }
    }
}