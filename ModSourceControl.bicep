param paraRepositoryUrl string
param paraBranch string
param paraisManualIntegration bool
param srcName string

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  name: srcName
  kind: 'Linux'
  properties: {
    repoUrl: paraRepositoryUrl
    branch: paraBranch
    isManualIntegration: paraisManualIntegration 
  }
}
