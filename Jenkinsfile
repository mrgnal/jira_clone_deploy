pipeline{
    agent {
        label 'agent1'
    }
    
    parameters  {
        string(name: 'DATABASE_URL', defaultValue: 'file:./test.db', description: 'Database Url')
        string(name: 'NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY', defaultValue: 'fake', description: 'Clerk public key')
        string(name: 'CLERK_SECRET_KEY', defaultValue: 'fake', description: 'Clerk private key')
        string(name: 'UPSTASH_REDIS_REST_URL', defaultValue: 'https://fake', description: 'Reddis url')
        string(name: 'UPSTASH_REDIS_REST_TOKEN', defaultValue: 'fake', description: 'Reddis token')
        string(name: 'NODE_ENV', defaultValue:'test', description:'Enviroment')
    }

    environment {
        BUILD_DIR = 'build'
        ZIP_NAME = "release-${env.BUILD_NUMBER}.zip"

        DATABASE_URL = "${params.DATABASE_URL}"
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

                echo 'Start lint'
                sh 'npm run lint'
            }
        }

        stage('Test'){
            steps{
                sh 'npm run test'
            }
        }

        stage('Build') {
             steps {
                echo 'Re-generating Prisma Client for production (PostgreSQL)...'
                sh 'npm run generate'

                echo 'Building app...'
                sh 'npm run build'
            }
        }

        stage('Archive') {
            steps {
                sh "zip -r ${env.ZIP_NAME} ${env.BUILD_DIR}"
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

    }

}