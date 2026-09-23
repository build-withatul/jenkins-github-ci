pipeline {

    agent any

    options {
        timeout(time: 10, unit: 'MINUTES')

        buildDiscarder(
            logRotator(
                numToKeepStr: '10',
                artifactNumToKeepStr: '5'
            )
        )
    }

    environment {
        APP_NAME = 'jenkins-github-ci'

        DEV_DIR  = '/opt/jenkins-demo/dev'
        QA_DIR   = '/opt/jenkins-demo/qa'
        PROD_DIR = '/opt/jenkins-demo/prod'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }

            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar',
                                 fingerprint: true
            }
        }

        stage('Deploy to DEV') {
            steps {
                sh '''
                    rm -f ${DEV_DIR}/*.jar
                    cp target/*.jar ${DEV_DIR}/
                '''

                echo 'Application deployed to DEV'
            }
        }

        stage('Deploy to QA') {
            steps {
                sh '''
                    rm -f ${QA_DIR}/*.jar
                    cp target/*.jar ${QA_DIR}/
                '''

                echo 'Application deployed to QA'
            }
        }

        stage('Production Approval') {
            steps {
                input message: 'Deploy application to PRODUCTION?',
                      ok: 'Deploy to Production'
            }
        }

        stage('Deploy to PROD') {
            steps {
                sh '''
                    rm -f ${PROD_DIR}/*.jar
                    cp target/*.jar ${PROD_DIR}/
                '''

                echo 'Application deployed to PRODUCTION'
            }
        }
    }

    post {

        success {
            echo 'CI/CD Pipeline completed successfully!'
        }

        failure {
            echo 'CI/CD Pipeline failed!'
        }

        always {
            echo 'Pipeline execution completed.'
        }
    }
}
