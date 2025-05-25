pipeline{
    agent {
        label 'agent1'
    }
    
    parameters  {
        string(name: 'DB_NAME', defaultValue: 'test_db', description: 'Test database name')
        string(name: 'DB_USER', defaultValue: 'user', description: 'Test database user')
        string(name: 'DB_PASSWORD', defaultValue: 'password', description: 'Test database password')
        string(name: 'DB_HOST', defaultValue: 'localhost', description: 'Database host')
        string(name: 'DB_PORT', defaultValue: '5432', description: 'Database port')
        string(name: 'NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY', defaultValue: 'fake', description: 'Clerk public key')
        string(name: 'CLERK_SECRET_KEY', defaultValue: 'fake', description: 'Clerk private key')
        string(name: 'UPSTASH_REDIS_REST_URL', defaultValue: 'https://fake', description: 'Reddis url')
        string(name: 'UPSTASH_REDIS_REST_TOKEN', defaultValue: 'fake', description: 'Reddis token')
        string(name: 'NODE_ENV', defaultValue:'test', description:'Enviroment')
    }

    environment {
        BUILD_DIR = './build'
        ZIP_NAME = "release-${BUILD_NUMBER}.zip"

        DATABASE_URL = "postgresql://${params.DB_USER}:${params.DB_PASSWORD}@${params.DB_HOST}:${params.DB_PORT}/${params.DB_NAME}"
        NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="${params.NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY}"
        CLERK_SECRET_KEY="${params.CLERK_SECRET_KEY}"
        UPSTASH_REDIS_REST_URL="${params.UPSTASH_REDIS_REST_URL}"
        UPSTASH_REDIS_REST_TOKEN="${params.UPSTASH_REDIS_REST_TOKEN}"
    }

    stages {
        stage('Lint') {
        steps {
                echo 'Setting dependencies'
                sh 'npm install'
                sh 'npm install ts-node typescript'

                echo 'Start lint'
                sh 'npm run lint'
            }
        }

        stage('Set up docker database'){
            steps{
                sh """
                sudo docker run -d \
                --name pg_test \
                -p ${params.DB_PORT}:5432 \
                -e POSTGRES_USER=${params.DB_USER} \
                -e POSTGRES_PASSWORD=${params.DB_PASSWORD} \
                -e POSTGRES_DB=${params.DB_NAME} \
                postgres:latest
                """
            }
        }

        stage('Waiting for database'){
            steps{
                sh """
                until sudo docker exec pg_test pg_isready -U ${params.DB_USER}; do
                echo "Waiting for Postgres..."; sleep 1;
                done
                """
            }
        }

        stage('Apply migrations'){
            steps{
                echo "Apply deploy migrate"
                sh 'npx prisma migrate deploy'

                echo "Apply seed migrate"
                sh 'npx prisma db seed'
            }
        }

        stage('Test'){
            steps{
                sh 'npm run test'
            }
        }

        stage('Build') {
             steps {
                echo 'Building app'
                sh 'npm run build'
            }
        }

        stage('Archive') {
            steps {
                sh "zip -r ${env.ZIP_NAME} ."
                archiveArtifacts artifacts: "${env.ZIP_NAME}", fingerprint: true
            }
        }
    }

    post{
        success{
            echo 'Pipeline finnished sccessfully'
        } 
        failure{
            echo 'Pipeline failed'
        }
        always{
            sh 'sudo docker stop pg_test || true'
            sh 'sudo docker rm pg_test || true'
        }
    }

}