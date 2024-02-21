param paraRepositoryUrl string
param paraBranch string


resource srcControls 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  name: 'web/'
  kind: 'Linux'
  properties: {
    repoUrl: paraRepositoryUrl
    branch: paraBranch
    isManualIntegration: true 
  }
}
