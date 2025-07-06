pipeline {
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
    AWS_CREDENTIALS_ID = 'jenkins-ecr-access'
    APP_NAME = 'jira_clone'
  }

  stages {
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

    stage('Lint') {
      steps {
        sh 'npm run lint'
      }
    }

    stage('Test') {
      steps {
        sh 'npm run test'
      }
    }

    stage('SonarQube') {
      steps {
        script {
          def scannerHome = tool 'sonarqube'
          withSonarQubeEnv('sonarqube') {
            sh "${scannerHome}/bin/sonar-scanner"
          }
        }
      }
    }


    stage('Test') {
      steps {
        sh 'npm run test'
      }
    }

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
        snykSecurity(
          snykInstallation: 'snyk',
          snykTokenId: 'snyk',
          failOnIssues: false
        )
      }
    }
    // stage('Code Analysis') {
    // steps {
    //     parallel (
    //     "Test": {
    //         sh 'npm run test'
    //     },
    //     "SonarQube Analysis": {
    //         script {
    //         def scannerHome = tool 'sonarqube'
    //         withSonarQubeEnv('sonarqube') {
    //             sh "${scannerHome}/bin/sonar-scanner"
    //         }
    //         }
    //     },
    //     "Snyk test": {
    //         snykSecurity(
    //         snykInstallation: 'snyk',
    //         snykTokenId: 'snyk',
    //         failOnIssues: false
    //         )
    //     }
    //     )
    // }
    // }


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
          image.tag("${env.NODE_ENV}-${env.BUILD_NUMBER}")
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
    } 
    failure {
      echo 'Pipeline failed'
    }
  }
}