param paralocation string 

@secure()
param paraUser string

@secure()
param paraUserPass string

param paraRtToFw string
param KVname string
param paravmName string
param paraTenantID string
param paraKVCoreObjectID string
param paraKVprivateEndpointName string
param paraKVprivateDnsZoneID string


param paraAspPrivateDnsZoneName string
param paraSQLprivateDnsZoneName string
param paraStprivateDnsZoneName string
param paraKVprivateDnsZoneName string

// ----------- Virtual Network Core --------------
resource vnetCore 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-Core'
  location: paralocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.20.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'KVSubnet'
        properties: {
          addressPrefix: '10.20.2.0/24'
          networkSecurityGroup:{
            id:nsgKVcore.id
          }
          routeTable:{
            id: paraRtToFw
          }
        }
      }
      {
        name: 'VMSubnet'
        properties: {
          addressPrefix: '10.20.1.0/24'
          networkSecurityGroup:{
            id:nsgvm1core001.id
          }
          routeTable:{
            id: paraRtToFw
          }
        }
      }
    ]
  }
  resource VMSubnet 'subnets' existing = {
    name: 'VMSubnet'
  }

  resource KVSubnet 'subnets' existing = {
    name: 'KVSubnet'
  }

}


// -------------- VM and dependecies -----------
resource nsgvm1core001 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-vm1core001'
  location: paralocation
  properties: {}
}

resource nicvm1core001 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'nic-vm1core001'
  location: paralocation
  properties: {
    ipConfigurations: [
      {
        name: 'deafult'
        properties: {
          
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnetCore::VMSubnet.id
          }
        }
        
      }
    ]
  }
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: paravmName
  location: paralocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2S_v3'
    }
    osProfile: {
      computerName: 'VM1-core001'
      adminUsername: paraUser
      adminPassword: paraUserPass
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: 'Disk'
        createOption:'FromImage'
        caching: 'ReadOnly'
        
        
      }

      

    }

    networkProfile: {
      networkInterfaces: [
       {
        id: nicvm1core001.id
        
       }
      ]
      
    }
    
  }
}

//------------ antoMalwareExtension ----------

resource antiMalwareExtension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  parent: windowsVM
  name: 'antiMalwareExtension'
  location: paralocation
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: 'true'
    }

  }
}

//----------- AMA Agent Extension -----------


resource windowsAgent 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  parent: windowsVM
  name: 'AzureMonitorWindowsAgent'
  location: paralocation
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}
// --------------- Key Vault ----------------

resource nsgKVcore'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-kv-core'
  location: paralocation
  properties: {}
}


resource reskv 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: KVname
  location: paralocation
  properties: {
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    tenantId: paraTenantID
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    accessPolicies: [
      {
        objectId: paraKVCoreObjectID
        tenantId: paraTenantID
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
   
  }
}

resource KVprivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: paraKVprivateEndpointName
  location: paralocation
  properties: {
    subnet: {
      id: vnetCore::KVSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: paraKVprivateEndpointName
        properties: {
          privateLinkServiceId: reskv.id
          groupIds: [
            'vault'
            
          ]
        }
      }
    ]
  }
}



resource KVEndPointDNSGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: KVprivateEndpoint
  name: 'kv-groupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: paraKVprivateDnsZoneID
        }
      }
    ]
  }
}



//--------------------- Private DNS zone Links --------------------------------


resource SQLprivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${paraSQLprivateDnsZoneName}/${vnetCore.name}SQLDnsZonelink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnetCore.id
    }
  }
}

resource StprivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  
  name: '${paraStprivateDnsZoneName}/${vnetCore.name}StDnsZoneLink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnetCore.id
    }
  }
}

resource aspPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${paraAspPrivateDnsZoneName}/${vnetCore.name}aspDnsZoneLink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnetCore.id
    }
  }
} 

resource KvPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${paraKVprivateDnsZoneName}/${vnetCore.name}KvDnsZoneLink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnetCore.id
    }
  }
}



output vnetCore string = vnetCore.id
output outresKV string = reskv.id
