param paraRepositoryUrl string
param paraBranch string
param paraisManualIntegration bool

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  name: 'as-prod-001-ap/web'
  kind: 'Linux'
  properties: {
    repoUrl: paraRepositoryUrl
    branch: paraBranch
    isManualIntegration: paraisManualIntegration 
  }
}
