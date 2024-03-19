// param paraRepositoryUrl string
// param paraBranch string
// param paraisManualIntegration bool
// param srcName string

// resource srcControls 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
//   name: srcName
//   kind: 'Linux'
//   properties: {
//     repoUrl: paraRepositoryUrl
//     branch: paraBranch
//     isManualIntegration: paraisManualIntegration 
//     deploymentRollbackEnabled: false
//     isGitHubAction:false
//     isMercurial: false
//   }
// }

param paramsrcctrlname string
param paramAppServiceName string

resource resAppService 'Microsoft.Web/sites@2022-09-01' existing = {
  name: paramAppServiceName
}

resource resProdSrcControls 'Microsoft.Web/sites/sourcecontrols@2022-09-01' = {
  name: paramsrcctrlname
  kind: 'app'
  parent: resAppService
  properties: {
    repoUrl: 'https://github.com/Azure-Samples/dotnetcore-docs-hello-world'
    branch: 'master'
    deploymentRollbackEnabled: true
    isManualIntegration: true
    isGitHubAction: false
    isMercurial: false
      }
    }
