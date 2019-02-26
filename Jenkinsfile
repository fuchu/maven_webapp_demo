#!groovy
def gitBranches = 'master'
def gitCredentialsID = '4b8982a2-feb0-4e1b-863d-927965be0593'
def gitUrl = 'git@github.com:fuchu/maven_webapp_demo.git'
def toEmail = 'kevin.zhou@softtek.com'
def dockerCredentialsID = '99fce050-1f09-4f51-a798-f78bd8af8875'
def ContainerName = 'mavenjunittesttomcatdemo'
try {
    stage('SCMCheckout') {
        node('master') {
            properties([buildDiscarder(logRotator(artifactDaysToKeepStr: '', aeertifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '20')), pipelineTriggers([pollSCM('*/1 * * * *')])])
        }
        node('Docker-Host') {
            checkout([$class: 'GitSCM', branches: [[name: gitBranches]], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'CloneOption', depth: 0, noTags: false, reference: '', shallow: false, timeout: 60]], submoduleCfg: [], userRemoteConfigs: [[credentialsId: gitCredentialsID, url: gitUrl]]])
            stash includes: '**', name: 'SourceCode'
        }
    }
    parallel ('Build': {
        stage('Build') {
            node('Docker-Host') {
                unstash 'SourceCode'
                docker.image('kevin123zhou/maven').inside("-v $WORKSPACE:/usr/src/app"){
                    sh 'mvn install -Dmaven.test.skip=true'
                }
                stash name: 'war', includes: '**/target/*.war'
            }
        }
        stage('Package') {
            node('Docker-Host') {
                unstash 'war'
                    docker.withRegistry('https://registry.hub.docker.com',dockerCredentialsID){
                    docker.build(ContainerName).push('latest')
                }
            }
        }
    }, 'TestAndReports': {
        node('Docker-Host') {
            stage('Test') {
                unstash 'SourceCode'
                docker.image('kevin123zhou/maven').inside("-v $WORKSPACE:/usr/src/app"){
                   sh'mvn test cobertura:cobertura -Dcobertura.report.format=xml -Dmaven.test.failure.ignore -Dmaven.test.skip=true'
                }
            }
            stage('TestReports') {
                step([$class: 'CoberturaPublisher', autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: 'online_reservation_*/target/site/cobertura/*.xml', failNoReports: false, failUnhealthy: false, failUnstable: false, maxNumberOfBuilds: 0, onlyStable: false, sourceEncoding: 'ASCII', zoomCoverageChart: false])
                junit allowEmptyResults: true, keepLongStdio: true, testResults: '**/target/surefire-reports/*.xml'
            }
        }
    })
    stage('Deploy') {
        node(master) {
            sh "docker stack deploy -c docker-compose.yml myWebappDemo"
        }
    }
    notifySuccessful(toEmail)
}
catch(Exception e){
    currentBuild.result = "FAILED"
    throw e
}

//def notifyFailed(toEmail) {
//    emailext (
//        subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
//        body: '${JELLY_SCRIPT,template="html"}',
//        mimeType: 'text/html', 
//        to: toEmail
//    )
//}
//def notifySuccessful(toEmail) {
//    emailext (      
//        subject: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
//        body: '${JELLY_SCRIPT,template="html"}',
//        mimeType: 'text/html', 
//        to: toEmail
//    )
//}
