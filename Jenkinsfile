pipeline{
 agent amy
    stages{
             stage ('Code - Checkout') {
                 steps{
                   checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/csenapati12/mb.git']]]
                       }
               }
              stage ('get value') {
                  script{
                 steps{
                      echo "start CI/CD - api-gateway"
                    //  BUILD_NUMBER = VersionNumber(projectStartDate: '2017-05-22', versionNumberString: 'Integration-test${BUILDS_ALL_TIME}', versionPrefix:'',  worstResultForIncrement:'SUCCESS')
                      TAG_VALUE="test"
                      
                     }
                  }   
               }
                stage ('Tag-commit') {
                    steps{
                     withCredentials([usernamePassword(credentialsId: 'Bharathtest', passwordVariable: 'Bharathpass', usernameVariable: 'Bharath')]) {
                    sh '''

                    git tag '${TAG_VALUE}'
                    git remote set-url origin https://$Bharath:$Bharathpass@gitlab.com/SkyloTechnologies/platform/backend/cloud/api-gateway.git
                    git remote -v
                    git push origin '${TAG_VALUE}'

                      '''
                 }
          }
    }
}
