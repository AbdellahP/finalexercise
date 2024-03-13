param vmName string
param DCRId string

resource resVM 'Microsoft.compute/virtualMachines@2023-09-01' existing = {
  name: vmName
}

resource DCRAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: 'configurationAccessEndpoint'
  properties: {
    dataCollectionRuleId: DCRId
  }
  scope: resVM
}

