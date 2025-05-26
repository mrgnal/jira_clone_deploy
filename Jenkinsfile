pipeline{
    agent {
        label 'agent1'
    }
    
    parameters  {
        string(name: 'NODE_ENV', defaultValue:'test', description:'Enviroment')
    }

    environment {
        NODE_ENV = "${params.NODE_ENV}"
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