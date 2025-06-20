pipeline{
    agent {
        label 'agent1'
    }
    
    parameters  {
        string(name: 'NODE_ENV', defaultValue:'test', description:'Enviroment')
        string(name: 'SKIP_ENV_VALIDATION', defaultValue:'true', description:'Skip validation .env file')
    }

    environment {
        NODE_ENV = "${params.NODE_ENV}"
        SKIP_ENV_VALIDATION = "${params.SKIP_ENV_VALIDATION}"
        AWS_CREDENTIALS_ID='jenkins-ecr-access'
        APP_NAME = 'jira_clone'
    }

    stages {
        stage('Set tag') {
            steps {
                script {
                    env.TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                }
            }
        }
        stage('Setting dependencies'){
            steps{
                sh 'npm install'
                sh 'npm install ts-node typescript'
            }
        }

        stage('Lint') {
        steps {
                sh 'npm run lint'
            }
        }

        stage('Test'){
            steps{
                sh 'npm run test'
            }
        }

        stage('Build docker image'){
            steps{
                script {
                    image = docker.build("${env.APP_NAME}:${env.TAG}")
                }
            }
        }



        stage('Push docker image to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${env.ECR_REPO}", "ecr:${env.AWS_REGION}:${env.AWS_CREDENTIALS_ID}") {
                        image.push(env.TAG)
                        image.push('latest')
                }
                }

            }
        }
    }

    post{
        always {
            cleanWs()
        }
        success{
            echo 'Pipeline finnished sccessfully'
        } 
        failure{
            echo 'Pipeline failed'
        }
    }

}
