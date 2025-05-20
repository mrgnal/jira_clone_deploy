pipeline{
    agent any

    enviroment{
        BUILD_DIR = 'build'
        ZIP_NAME = "release-${env.BUILD_NUMBER}.zip"
    }

    stages {
        stage ('Lint'){
            steps {
                echo "Setting dependencies"
                sh 'npm install'
            }
            steps {
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

        stage('Build'){
            sh 'npm run build'
        }

        stage('Archive')
        {
            sh "zip -r ${env.ZIP_NAME} ${env.BUILD_DIR}"
            archiveArtifacts artifacts: "${env.ZIP_NAME}", fingerprint: true
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