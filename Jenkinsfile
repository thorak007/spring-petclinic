pipeline {
  environment {
    registry = "thorak2001/spring-petclinic"
    registryCredential = 'dockerhub'
  }
  agent {
    kubernetes {
      defaultContainer 'jnlp'
      yamlFile 'jenkins-slave.yaml'
    }
  }
  stages {
    stage('CHECKOUT') {
      steps {
        container('toolbox') {
          checkout scm
        }
      }
    }
    stage('TEST') {
      steps {
        container('toolbox') {
          script {
            sh """
              docker build --network=host -t ${registry}:${env.BUILD_NUMBER} --target test .
            """
          }
        }
      }
    }
    stage('BUILD') {
      steps {
        container('toolbox') {
          script {
            sh """ 
              docker build --network=host -t ${registry}:${env.BUILD_NUMBER} --target production .
            """
          }
        }
      }
    }
    stage('CREATE ARTIFACT') {
      steps {
        container('toolbox') {
          script {
            docker.withRegistry( '', registryCredential ) {
              sh """
                docker push "${registry}:${env.BUILD_NUMBER}"
              """
            }
          }
        }
      }
    }
    stage('DEPLOY CI') {
      when {
        branch 'develop'
      }
      steps {
        container('toolbox') {
          script {
            sh """
              helm repo add app-chart https://thorak007.github.io/app-chart
              helm repo update
              helm upgrade app-release-dev app-chart/mychart --set deploy.containerTag=${env.BUILD_NUMBER} -n dev --reuse-values
            """
          }
        }
      }
    }
    stage('DEPLOY QA') {
      when {
        branch 'master'
      }
      steps {
        container('toolbox') {
          script {
            sh """
              helm repo add app-chart https://thorak007.github.io/app-chart
              helm repo update
              helm upgrade app-release-prod app-chart/mychart --set deploy.containerTag=${env.BUILD_NUMBER} -n prod --reuse-values
            """
          }
        }
      }
    }
  }
}
