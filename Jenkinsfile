pipeline{
    agent {
        label 'agent1'
    }
    
    parameters  {
        string(name: 'DATABASE_URL', defaultValue: 'postgresql://fake', description: 'Database Url')
        string(name: 'NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY', defaultValue: 'fake', description: 'Clerk public key')
        string(name: 'CLERK_SECRET_KEY', defaultValue: 'fake', description: 'Clerk private key')
        string(name: 'UPSTASH_REDIS_REST_URL', defaultValue: 'https://fake', description: 'Reddis url')
        string(name: 'UPSTASH_REDIS_REST_TOKEN', defaultValue: 'fake', description: 'Reddis token')

        string(name: 'NODE_ENV', defaultValue:'test', description:'Enviroment')

    }

    environment {
        NODE_ENV = "${params.NODE_ENV}"

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
                sh 'npm install ts-node typescript'

                echo 'Start lint'
                sh 'npm run lint'
            }
        }

        stage('Test'){
            steps{
                sh 'npm run test'
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