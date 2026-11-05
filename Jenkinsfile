pipeline {
    agent { label 'podman-agent' }

    triggers {
        pollSCM('H/2 * * * *')
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        REGISTRY = 'registry.assign.109952234.300.ops:5000'
        IMAGE    = "${REGISTRY}/ops300/bind-secondary"
    }

    stages {
        stage('Build image') {
            steps {
                script {
                    env.TAG = "${env.BUILD_NUMBER}"
                }
                sh 'podman build --network host -t "$IMAGE:$TAG" .'
            }
        }

        stage('Push to private registry') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'registry-credentials',
                    usernameVariable: 'REG_USER',
                    passwordVariable: 'REG_PASS'
                )]) {
                    sh '''
                        set -eu
                        printf '%s' "$REG_PASS" | podman login "$REGISTRY" -u "$REG_USER" --password-stdin
                        podman push "$IMAGE:$TAG"
                    '''
                }
            }
        }
    }
}
