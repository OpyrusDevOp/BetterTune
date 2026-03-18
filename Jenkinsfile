pipeline {
    agent none  // defined per stage

    environment {
        IMAGE_NAME     = 'bettertune-web'
        CONTAINER_NAME = 'bettertune'
        HOST_PORT      = '8085'  // NPM proxies bettertune.home.lab → this port
    }

    stages {

        // ── Stage 1: build inside a disposable Flutter container ─────────────
        stage('Build Web') {
            agent {
                docker {
                    image 'ghcr.io/cirruslabs/flutter:stable'
                    args  '-u root --entrypoint=""'
                    label 'agent-1'
                }
            }
            steps {
                sh 'flutter --version'
                sh 'flutter pub get'
                sh 'flutter analyze --no-fatal-infos'
                sh 'flutter test'
                sh 'flutter build web --release --base-href /'

                // Pass the build output to the next stage
                stash name: 'web-build', includes: 'build/web/**'
            }
        }

        // ── Stage 2: build Docker image and deploy on the host ───────────────
        // Runs directly on agent-1 (no Docker wrapper).
        // Requires /var/run/docker.sock mounted in the agent-1 container
        // so docker commands reach the HOST daemon, not a nested one.
        stage('Deploy') {
            when {
                branch 'main'
            }
            agent {
                label 'agent-1'
            }
            steps {
                unstash 'web-build'

                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -t ${IMAGE_NAME}:latest ."

                sh """
                    docker stop ${CONTAINER_NAME} || true
                    docker rm   ${CONTAINER_NAME} || true

                    docker run -d \
                        --name    ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p ${HOST_PORT}:80 \
                        ${IMAGE_NAME}:latest
                """

                // Remove dangling images from old builds
                sh 'docker image prune -f'
            }
        }
    }

    post {
        success {
            echo "Live at: http://bettertune.home.lab  (via NPM → port ${HOST_PORT})"
        }
        failure {
            echo 'Pipeline failed. Check the stage logs above.'
        }
        always {
            // cleanWs runs on whichever agent last ran — safe to keep
            node('agent-1') {
                cleanWs()
            }
        }
    }
}
