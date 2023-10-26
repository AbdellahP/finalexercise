param paralocation string
param paralogAnalyticsName string
 

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: paralogAnalyticsName
  location: paralocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90 
    forceCmkForQuery: false
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    features: {
      disableLocalAuth: false
      enableLogAccessUsingOnlyResourcePermissions: true
    }

    workspaceCapping: {
      dailyQuotaGb: -1
    }
  }
}

output outLogAnalytics string = logAnalytics.id
