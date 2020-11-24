TAG_VALUE =''
pipeline{
 agent any
    stages{
             stage ('Code - Checkout') {
                 steps{
                   checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/csenapati12/mb.git']]]
                       }
               }
              stage ('get value') {                  
                 steps{
                    script{ 
                      echo "start CI/CD - api-gateway"
                    //  BUILD_NUMBER = VersionNumber(projectStartDate: '2017-05-22', versionNumberString: 'Integration-test${BUILDS_ALL_TIME}', versionPrefix:'',  worstResultForIncrement:'SUCCESS')
                      TAG_VALUE="test"
                      
                     }
                   echo "1111111111111 ${TAG_VALUE}"
                  }   
               }
                stage ('Tag-commit') {
                    steps{
                      echo "22222222222 ${TAG_VALUE}"
                     withCredentials([usernamePassword(credentialsId: 'Test-lab', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                       echo "333333333333333 ${TAG_VALUE}"
                    sh """

                    git tag ${TAG_VALUE}
                    git remote set-url origin https://$USERNAME:$PASSWORD@github.com/csenapati12/mb.git
                    git remote -v
                    git push origin ${TAG_VALUE}

                     """
                 }
          }
       }          
    }
}
