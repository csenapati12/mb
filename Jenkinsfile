node(){
    properties([buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '2', numToKeepStr: '')), parameters([choice(choices: ['DEV', 'QA', 'UAT', 'PROD'], description: 'Please select the environment for deploy', name: 'ENV')])])
stage("code checkout"){
    echo "checkout" 
    checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: '*/develop']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'githubcredentials', url: 'https://github.com/csenapati12/java-tomcat-maven-example.git']]]
}
stage("mvn build"){
    echo "maven build" 
    sh label: '', script: 'mvn package'
}
stage("Deploy"){
    echo "Execute shell" 
   sh label: '', script: '''ls /var/lib/jenkins
cd /var/lib/jenkins/workspace/scripted-pipeline/target
cp java-tomcat-maven-example.war /var/lib/jenkins
ls /var/lib/jenkins'''
}

}
