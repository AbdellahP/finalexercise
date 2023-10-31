param paralocation string 
param paraAppSubnetAddressPrefix string
param paraSqlSubnetAddressPrefix string 
param paraStSubnetAddressPrefix string
param paraVnetAddressPrefix string
param paraVnetName string
param parasku string 
param paraRepositoryUrl string  
param paraBranch string

param paraAppServicePlanName string
param paraAppService string
param paraAspPrivateEndpointName string


param paraSQLprivateEndpointName string
param sqlServerName string


param parastorageAccountType string
param parastorageAccountName string
param paracontainerName string
param paraStprivateEndpointName string

param paraRtToFw string

param nsgASPname string
param nsgSQLname string
param nsgStname string

param paralogAnalytics string

param DepartmentNameTag string

//----not used----


//output parameters for DNS zone name
param paraAspPrivateDnsZoneName string
param paraSQLprivateDnsZoneName string
param paraStprivateDnsZoneName string
param paraKVprivateDnsZoneName string

//output parameters for DNS Zone ID
param paraAspPrivateDnsZoneID string
param paraSQLprivateDnsZoneID string
param paraStprivateDnsZoneID string
param paraKVprivateDnsZoneID string


// param paraPrivateDnsZoneLinkName string

@secure()
param paraUserLogin string
@secure()
param paraUserPassword string



resource vnetSpoke 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: paraVnetName
  location: paralocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        paraVnetAddressPrefix
      ]
    }

    subnets: [
      {
        name: 'AppSubnet'
        properties: {
          addressPrefix: paraAppSubnetAddressPrefix
          routeTable:{
            id: paraRtToFw
          }
          networkSecurityGroup:{
            id:nsgAppServicePlan.id
          }
         
        }
        
      }
      {
        name: 'SqlSubnet'
        properties: {
          addressPrefix: paraSqlSubnetAddressPrefix
          routeTable:{
            id: paraRtToFw
          }
          networkSecurityGroup: {
            id:nsgSql.id
          }
        }
      }
      {
        name: 'StSubnet'
        properties: {
          addressPrefix: paraStSubnetAddressPrefix
          routeTable:{
            id: paraRtToFw
          }
        }
      }
    ]
  }

  resource AppSubnet 'subnets' existing = {
    name: 'AppSubnet'
   
  }

  resource SqlSubnet 'subnets' existing = {
    name: 'SqlSubnet'
  }

  resource StSubnet 'subnets' existing = {
    name: 'StSubnet'
  }
}


// ------------------------ App service Plan --------------------------

resource nsgAppServicePlan 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgASPname
  location: paralocation
  properties: {}
}


resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: paraAppServicePlanName
  location: paralocation
  properties: {
    reserved: true
  }
  sku: {
    name: parasku
  }
  kind: 'linux'
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: paraAppService 
  location: paralocation
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|7.0'
      
    }
  }
}

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  parent: appService
  name: 'web'
  kind: 'Linux'
  properties: {
    repoUrl: paraRepositoryUrl
    branch: paraBranch
    isManualIntegration: true 
  }
}

resource aspPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: paraAspPrivateEndpointName
  location: paralocation
  properties: {
    subnet: {
      id: vnetSpoke::AppSubnet.id
    }
    privateLinkServiceConnections: [ 
      {
        name: paraAspPrivateEndpointName
        properties: {
          privateLinkServiceId:appService.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}


resource aspEndPointDNSGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: aspPrivateEndpoint
  name: 'ASPgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: paraAspPrivateDnsZoneID
        }
      }
    ]
  }
}


// ----------------------SQL DATABASE ----------------------------

resource nsgSql 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgSQLname
  location: paralocation
  properties: {}
}


resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: paralocation
  properties: {
    administratorLogin: paraUserLogin
    administratorLoginPassword:paraUserPassword
    // version: '12.0'
    publicNetworkAccess:  'Disabled'
  }
}

resource database 'Microsoft.Sql/servers/databases@2023-02-01-preview' = {
  parent: sqlServer
  name:'sqldb-dev-001'
  location: paralocation
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    // collation: 'SQL_Latin1_General_CP1_CI_AS'
    // maxSizeBytes: 104857600
    // sampleName: 'AdventureWorksLT'
  }
 
}

resource SQLprivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: paraSQLprivateEndpointName
  location: paralocation
  properties: {
    subnet: {
      id: vnetSpoke::SqlSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: paraSQLprivateEndpointName
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}




resource SQLEndPointDNSGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: SQLprivateEndpoint
  name: 'DNSgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: paraSQLprivateDnsZoneID
        }
      }
    ]
  }
}


// --------------------- Storage account --------------------------- 

resource nsgSt 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgStname
  location: paralocation
  properties: {}
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: parastorageAccountName
  location: paralocation
  sku: {
    name: parastorageAccountType
  }

  kind: 'StorageV2'
  properties:{}
}


resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: paracontainerName
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}



resource StprivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: paraStprivateEndpointName
  location: paralocation
  properties: {
    subnet: {
      id: vnetSpoke::StSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: paraStprivateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}


resource StEndPointDNSGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: StprivateEndpoint
  name: 'StpvtEndpointDNSgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: paraStprivateDnsZoneID
        }
      }
    ]
  }
}



//------------ Private DNS zone Links --------------------

resource SQLprivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${paraSQLprivateDnsZoneName}/${vnetSpoke.name}SQLDnsZonelink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnetSpoke.id
    }
  }
}

resource StprivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  
  name: '${paraStprivateDnsZoneName}/${vnetSpoke.name}StDnsZoneLink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnetSpoke.id
    }
  }
}

resource aspPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${paraAspPrivateDnsZoneName}/${vnetSpoke.name}aspDnsZoneLink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnetSpoke.id
    }
  }
} 

resource KvPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${paraKVprivateDnsZoneName}/${vnetSpoke.name}KvDnsZoneLink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnetSpoke.id
    }
  }
}

//----------------- Tags --------------------------

resource aspTag 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  scope: appServicePlan
  properties: {
    tags: {
      Dept: DepartmentNameTag
      
    }
  }
}

resource StAccountTag 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  scope: storageAccount
  properties: {
    tags: {
      Dept: DepartmentNameTag
      
    }
  }
}

resource SqlServerTag 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  scope: sqlServer
  properties: {
    tags: {
      Dept: DepartmentNameTag
      
    }
  }
}
output Prodfqdn string = appService.properties.defaultHostName
output outStAccountEP string = storageAccount.properties.primaryEndpoints.blob

output outVnetSpokeName string = vnetSpoke.name
output outVnetSpokeID string= vnetSpoke.id

