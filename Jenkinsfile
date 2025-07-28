pipeline {
    agent any
    
    parameters {
        string(name: 'NODE_ENV', defaultValue:'test', description:'Environment')
        string(name: 'SKIP_ENV_VALIDATION', defaultValue:'true', description:'Skip validation .env file')
        booleanParam(name: 'BUILD_MIGRATION_IMAGE', defaultValue: true, description: 'Build migration image or not')
    }
    environment {
        NODE_ENV = "${params.NODE_ENV}"
        SKIP_ENV_VALIDATION = "${params.SKIP_ENV_VALIDATION}"
        AWS_CREDENTIALS_ID = 'jenkins-ecr-access'
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

        stage('Setting dependencies') {
            when {
                expression { return params.NODE_ENV != 'production' }
            }
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
                        //   stage('SonarQube Analysis') {
                        //     steps {
                        //         script {
                        //             def scannerHome = tool 'sonarqube'
                        //             withSonarQubeEnv('sonarqube') {
                        //                 sh "${scannerHome}/bin/sonar-scanner"
                        //             }
                        //         }
                        //     }
                        // }
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
                                            description: "Snyk Test Failed: build ${env.BUILD_NUMBER}.",
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
                    env.GIT_BRANCH_CLEAN = env.GIT_BRANCH?.replaceAll(/^origin\//, '')?.replaceAll('/', '-') ?: 'unknown'
                    env.IMAGE_TAG = "${env.GIT_BRANCH_CLEAN}-${env.GIT_HASH}-${env.DATE}"
                }
            }
        }
        stage('Build & push images'){
            parallel{
                stage ('Build & push app'){
                stages{
                    stage('Login to ECR') {
                    steps {
                        withAWS(region: "${env.AWS_REGION}"){
                            sh """
                                aws ecr get-login-password --region ${env.AWS_REGION} | \
                                docker login --username AWS --password-stdin ${env.ECR_APP_URI}
                            """
                        }
                    }
                }        
                    stage('Build app docker image') {
                        steps {
                            script {
                                image = docker.build("${env.ECR_APP_URI}/${env.APP_NAME}:${env.IMAGE_TAG}")
                                image.tag("latest")
                                image.tag("Build-${env.BUILD_NUMBER}")
                            }
                        }
                    }
                    stage('Push docker image to ECR') {
                        steps {
                            script {
                                image.push("${env.IMAGE_TAG}")
                                image.push('latest')
                                image.push("Build-${env.BUILD_NUMBER}")
                            }
                        }
                    }
                }
                }
                stage('Build & push migration image'){
                when {
                    expression { return params.BUILD_MIGRATION_IMAGE == true }
                }
                stages {
                    stage('Login to ECR') {
                    steps {
                        withAWS(region: "${env.AWS_REGION}"){
                            sh """
                                aws ecr get-login-password --region ${env.AWS_REGION} | \
                                docker login --username AWS --password-stdin ${env.ECR_APP_URI}
                            """
                        }
                    }
                }        
                    stage('Build migration docker image') {
                        steps {
                            script {
                                image = docker.build("${env.ECR_APP_URI}/${env.MIGRATION_NAME}:${env.IMAGE_TAG}", "-f Dockerfile.migrate .")
                                image.tag("latest")
                                image.tag("Build-${env.BUILD_NUMBER}")
                            }
                        }
                    }
                    stage('Push docker image to ECR') {
                        steps {
                            script {
                                image.push("${env.IMAGE_TAG}")
                                image.push('latest')
                                image.push("Build-${env.BUILD_NUMBER}")
                            }
                        }
                    }
                }
                }

            }
        }
        
    }
    post {
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