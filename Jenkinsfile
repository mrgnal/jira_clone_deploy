pipeline{
    agent {
        label 'agent1'
    }

    environment {
        BUILD_DIR = 'build'
        ZIP_NAME = "release-${env.BUILD_NUMBER}.zip"

        DATABASE_URL = credentials('DATABASE_URL')
        NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=credentials('DATABASE_URLNEXT_PUBLIC_CLERK_PUBLISHABLE_KEY')
        CLERK_SECRET_KEY=credentials('CLERK_SECRET_KEY')
        UPSTASH_REDIS_REST_URL=credentials('UPSTASH_REDIS_REST_URL')
        UPSTASH_REDIS_REST_TOKEN=credentials('UPSTASH_REDIS_REST_TOKEN')
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

        stage('Start app'){
            steps {
                sh 'npm run start'
            }
        }

        // stage('Test'){
        //     steps{
        //         sh 'npm run test'
        //     }
        // }

        stage('Build') {
            steps {
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