#!groovy
def gitBranches = 'master'
def gitCredentialsID = 'c4a4c9e0-003e-440a-afe8-bd621ffcf515'
def gitUrl = 'git@github.com:fuchu/maven_webapp_demo.git'
def toEmail = 'kevin.zhou@softtek.com'
def dockerCredentialsID = '99fce050-1f09-4f51-a798-f78bd8af8875'
def ContainerName = 'mavenjunittesttomcatdemo'
try{
    stage('SCMCheckout') {
    	node('master') {
    		properties([buildDiscarder(logRotator(artifactDaysToKeepStr: '', aeertifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '20')), pipelineTriggers([pollSCM('*/1 * * * *')])])
    	}
    	node('docker') {
    		checkout([$class: 'GitSCM', branches: [[name: gitBranches]], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'CloneOption', depth: 0, noTags: false, reference: '', shallow: false, timeout: 60]], submoduleCfg: [], userRemoteConfigs: [[credentialsId: gitCredentialsID, url: gitUrl]]])
    		stash includes: '**', name: 'SourceCode'
    	}
    }
    parallel 'Build': {
    	stage('Build') {
    		node('docker') {
    			unstash 'SourceCode'
    			docker.image('kevin123zhou/maven').withrun(-v "'$WORKSPACE':/usr/src/webapp" --rm){
    				maven install -Dmaven.test.skip=true
    			}
    			stash name: 'war', includes: '**/target/*.war'
    		}
    	}
    	stage('Package') {
    		node('docker') {
    			unstash 'war'
    			docker.withRegistry('registry.hub.docker.com',dockerCredentialsID){
    				docker.build(ContainerName).push('lastest')
    			}
    		}
    	}
    }, 'TestAndReports': {
    	node('docker') {
    		stage('Test') {
    			unstash 'SourceCode'
    			docker.image('kevin123zhou/maven').withrun(-v "'$WORKSPACE':/usr/src/webapp" --rm){
    				maven test cobertura:cobertura -Dcobertura.report.format=xml -Dmaven.test.failure.ignore -Dmaven.test.skip=true
    			}
    		}
    		stage('TestReports') {
    			step([$class: 'CoberturaPublisher', autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: 'online_reservation_*/target/site/cobertura/*.xml', failNoReports: false, failUnhealthy: false, failUnstable: false, maxNumberOfBuilds: 0, onlyStable: false, sourceEncoding: 'ASCII', zoomCoverageChart: false])
    			junit allowEmptyResults: true, keepLongStdio: true, testResults: '**/target/surefire-reports/*.xml'
    		}
    	}
    }

    stage('Deploy') {
    	node(master) {
    		sh "docker stack deploy -c docker-compose.yml myWebappDemo"
    	}
    	// node('ansible') {
    	// 	unstash 'war'
    	// 	unstash 'AnsibleFile'
    	// 	sh 'ansible-playbook deploy_online_build_azure.yml --extra-vars "varsfile=staging_vars_azure_appstaging"'
    	// }
    }
    notifySuccessful(toEmail)
}
catch(Exception e){
    currentBuild.result = "FAILED"
	//触发失败邮件
    //notifyFailed(toEmail)
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