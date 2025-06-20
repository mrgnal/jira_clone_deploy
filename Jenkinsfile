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
        AWS_CREDENTIALS_ID='AWS_CREDENTIALS_ID'
        APP_NAME = 'jira-clone'
        TAG='latest'
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
                    image.tag('latest')
                }
                // sh "sudo docker build -f Dockerfile -t ${env.APP_NAME}:${env.} ."
            }
        }

        // stage('Docker login to ECR') {
        //     steps {
        //         withAWS(credentials: "${env.AWS_CREDENTIALS_ID}", region: "${env.AWS_REGION}") {
        //             script {
        //                 sh '''
        //                     aws ecr get-login-password --region $AWS_REGION | \
        //                     docker login --username AWS --password-stdin $ECR_REGISTRY
        //                 '''
        //             }
        //         }
        //     }
        // }

        stage('Push docker image to ECR') {
            steps {
                script {
                    docker.withRegistry("${env.ECR_REPO}", "ecr:${env.AWS_REGION}:${env.AWS_CREDENTIALS_ID}") {
                        image.push(env.TAG)
                        image.push('latest')
                }
                }
                // script {
                //     sh '''
                //         docker tag ${APP_NAME}:${TAG} ${ECR_REPO}:${TAG}
                //         docker push ${ECR_REPO}:${TAG}
                //     '''
                // }
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
