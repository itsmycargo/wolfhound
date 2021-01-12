#!groovy

defaultBuild()

pipeline {
  options {
    timeout(15)
    disableConcurrentBuilds()
  }

  agent { kubernetes {} }

  stages {
    stage("Build") {
      steps {
        buildDocker()
      }
    }
  }
}
