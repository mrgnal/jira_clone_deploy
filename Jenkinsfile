pipeline {
    agent {
        label 'agent1'
    }
    parameters {
        string(name: 'NODE_ENV', defaultValue:'test', description:'Environment')
        string(name: 'SKIP_ENV_VALIDATION', defaultValue:'true', description:'Skip validation .env file')
    }
    environment {
        NODE_ENV = "${params.NODE_ENV}"
        SKIP_ENV_VALIDATION = "${params.SKIP_ENV_VALIDATION}"
        AWS_CREDENTIALS_ID = 'jenkins-ecr-access'
        APP_NAME = 'jira_clone'
    }
    stages {
        stage('Discord notify') {
            steps {
                discordSend(
                    webhookURL: env.DISCORD_WEBHOOK,
                    title: env.JOB_NAME,
                    link: env.BUILD_URL,
                    description: "Pipeline started: build ${env.BUILD_NUMBER}",
                    result: 'ABORTED'
                )
            }
        }

        stage('SCM') {
            steps {
                checkout scm
            }
        }
        stage('Setting dependencies') {
            steps {
                sh 'npm install'
                sh 'npm install ts-node typescript'
            }
        }
        stage('Code Analysis') {
            parallel {
                stage('Lint') {
                    steps {
                        sh 'npm run lint'
                    }
                }
                stage('Security & Quality Analysis') {
                    stages {
                          stage('SonarQube Analysis') {
                            steps {
                                script {
                                    def scannerHome = tool 'sonarqube'
                                    withSonarQubeEnv('sonarqube') {
                                        sh "${scannerHome}/bin/sonar-scanner"
                                    }
                                }
                            }
                        }
                        stage('Snyk test') {
                            steps {
                                script{
                                    try{
                                    snykSecurity(
                                        snykInstallation: 'snyk',
                                        snykTokenId: 'snyk',
                                        // failOnIssues: false
                                    )
                                    }catch(err){
                                        echo "Snyk error: ${err}"

                                         discordSend(
                                            webhookURL: env.DISCORD_WEBHOOK,
                                            title: env.JOB_NAME,
                                            link: env.BUILD_URL,
                                            result: 'FAILURE'
                                        )
                                    }
                                }

                            }
                        }
                    }
                }
            }
        }
        stage('Test') {
            steps {
                sh 'npm run test'
            }
        }
        stage('Set tags') {
            steps {
                script {
                    env.GIT_HASH = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.DATE = sh(script: 'date +%Y%m%d-%H%M', returnStdout: true).trim()
                }
            }
        }
        stage('Build docker image') {
            steps {
                script {
                    image = docker.build("${env.APP_NAME}:${env.GIT_HASH}")
                    image.tag('latest')
                    image.tag(env.GIT_HASH)
                    image.tag("Build-${env.BUILD_NUMBER}")
                    image.tag(env.DATE)
                }
            }
        }
        stage('Push docker image to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${env.ECR_REPO}", "ecr:${env.AWS_REGION}:${env.AWS_CREDENTIALS_ID}") {
                        image.push(env.GIT_HASH)
                        image.push('latest')
                        image.push("${env.NODE_ENV}-${env.BUILD_NUMBER}")
                        image.push(env.DATE)
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline finished successfully'
            discordSend(
                webhookURL: env.DISCORD_WEBHOOK,
                title: env.JOB_NAME,
                link: env.BUILD_URL,
                description: "Pipeline success: build ${env.BUILD_NUMBER}",
                result: 'SUCCESS',
                showChangeset: true
            )
        }
        failure {
            echo 'Pipeline failed'
            discordSend(
                webhookURL: env.DISCORD_WEBHOOK,
                title: env.JOB_NAME,
                link: env.BUILD_URL,
                description: "Pipeline failed: build ${env.BUILD_NUMBER}",
                result: 'FAILURE',
                showChangeset: true
            )
        }
        aborted {
            echo 'Pipeline aborted'
            discordSend(
                webhookURL: env.DISCORD_WEBHOOK,
                title: env.JOB_NAME,
                link: env.BUILD_URL,
                description: "Pipeline aborted: build ${env.BUILD_NUMBER}",
                result: 'ABORTED'
            )
        }
    }
}