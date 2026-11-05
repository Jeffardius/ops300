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
        TRIVY_SEVERITY = 'HIGH,CRITICAL'
        TRIVY_EXIT_CODE = '1'
    }

    stages {
        stage('Build image') {
            steps {
                script {
                    env.TAG = "${env.BUILD_NUMBER}"
                }
                sh 'podman build --network host -t "$IMAGE:$TAG" -t "$IMAGE:latest" .'
            }
        }

        stage('Scan image for CVEs') {
            steps {
                sh '''
                    set -eu
                    mkdir -p "$HOME/.cache/trivy"
                    podman save -o image.tar "$IMAGE:$TAG"
                    trivy image \
                        --cache-dir "$HOME/.cache/trivy" \
                        --severity "$TRIVY_SEVERITY" \
                        --scanners vuln \
                        --format table \
                        --output trivy-report.txt \
                        --input image.tar
                    cat trivy-report.txt
                    trivy image \
                        --cache-dir "$HOME/.cache/trivy" \
                        --severity "$TRIVY_SEVERITY" \
                        --scanners vuln \
                        --exit-code "$TRIVY_EXIT_CODE" \
                        --no-progress \
                        --input image.tar
                    rm -f image.tar
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
                }
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
                        podman push "$IMAGE:latest"
                    '''
                }
            }
        }
    }
}
