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
        SONAR_TOKEN = credentials('sonar')
        SONAR_ORGANIZATION = 'rss-devops-course-tasks-romax114'
        SONAR_PROJECT_KEY = 'rss-devops-course-tasks_flask-app'
        DISCORD_WEBHOOK = credentials('discord-webhook-url')
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
                        python -m pip install pytest==7.4.0 pytest-cov==4.1.0
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
                        python -m safety check -r requirements.txt --output text > ../reports/safety-report.txt || true
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
                    catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                        withCredentials([string(credentialsId: 'sonar', variable: 'SONAR_TOKEN')]) {
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
                                  -Dsonar.python.coverage.reportPaths=coverage.xml \\
                                  -Dsonar.qualitygate.wait=false || echo "SonarCloud analysis failed but continuing pipeline"
                            '''
                        }
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
                    ./helm upgrade --install flask-app ./helm-charts/flask-app \\
                        --create-namespace \\
                        --namespace flask-app \\
                        -f ./helm-charts/flask-app/values-minikube.yaml \\
                        --set image.repository=${DOCKERHUB_CREDENTIALS_USR}/${IMAGE_NAME} \\
                        --set image.tag=${IMAGE_TAG} \\
                        --set image.pullPolicy=Always \\
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
                    
                    # Wait for pods to be ready
                    echo "\nWaiting for pods to be ready:"
                    kubectl wait --for=condition=ready pod -l app=flask-app -n flask-app --timeout=60s || true
                    
                    # Check if pods are running
                    echo "\nChecking pod status:"
                    ./helm status flask-app -n flask-app
                    kubectl get pods -n flask-app -o wide || echo "Could not get pods"
                    
                    # Check pod logs for any issues
                    echo "\nChecking pod logs:"
                    POD_NAME=$(kubectl get pods -n flask-app -l app=flask-app --field-selector=status.phase=Running -o jsonpath="{.items[0].metadata.name}")
                    if [ -n "$POD_NAME" ]; then
                        echo "Logs from pod $POD_NAME:"
                        kubectl logs $POD_NAME -n flask-app
                    else
                        echo "No running pods found"
                    fi
                    
                    # Get service name
                    echo "\nGetting service name:"
                    kubectl get svc -n flask-app
                    SERVICE_NAME=$(kubectl get svc -n flask-app -o name | head -1 | sed "s|service/||")
                    echo "Found service: ${SERVICE_NAME}"
                    
                    if [ -n "${SERVICE_NAME}" ]; then
                        # Kill any existing port-forward processes
                        echo "\nSetting up port forwarding..."
                        if command -v pkill >/dev/null 2>&1; then
                            pkill -f "port-forward" || echo "No existing port-forward to kill"
                        fi
                        
                        # Start port forwarding in the background
                        echo "Starting port-forward for service ${SERVICE_NAME}"
                        kubectl port-forward svc/${SERVICE_NAME} 8080:8080 -n flask-app &
                        PORT_FORWARD_PID=$!
                        
                        # Give it a moment to establish
                        sleep 5
                        
                        # Try to access the service via port-forward
                        echo "\nAttempting to access the service via port-forward..."
                        RESPONSE=$(curl -s http://localhost:8080/)
                        if [ "$RESPONSE" = "Hello, World!" ]; then
                            echo "✅ Application is running correctly! Response: $RESPONSE"
                        else
                            echo "❌ Unexpected response from application: $RESPONSE"
                            curl -v http://localhost:8080/ || echo "Service not accessible via port-forward"
                        fi
                        
                        # Clean up port-forward
                        if ps -p $PORT_FORWARD_PID >/dev/null 2>&1; then
                            echo "Killing port-forward process ${PORT_FORWARD_PID}"
                            kill $PORT_FORWARD_PID
                        else
                            echo "Port-forward process not found"
                        fi
                    else
                        echo "No service found in namespace flask-app"
                    fi
                '''
            }
        }
    }
    
    post {
        success {
            echo "Pipeline succeeded!"
            script {
                def message = "✅ Pipeline succeeded for build #${env.BUILD_NUMBER}! Application deployed successfully."
                sh """
                    curl -X POST -H "Content-Type: application/json" \\
                    -d '{"content": "${message}"}' \\
                    ${DISCORD_WEBHOOK}
                """
            }
        }
        failure {
            echo "Pipeline failed!"
            script {
                def message = "❌ Pipeline failed for build #${env.BUILD_NUMBER}! Check Jenkins for details."
                sh """
                    curl -X POST -H "Content-Type: application/json" \\
                    -d '{"content": "${message}"}' \\
                    ${DISCORD_WEBHOOK}
                """
            }
        }
        always {
            cleanWs()
        }
    }
}