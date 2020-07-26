node(){
    
    stage("checkout code"){
        checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/csenapati12/java-tomcat-maven-example.git']]]
        echo "checkout"
    }
    stage("Build"){
        sh label: '', script: 'mvn package'
        echo "Build"
    }
    stage("Sonar"){
        echo "sonar analysis"
    }
    
     stage("Rsync"){
        echo "Rsync"
    }
}
