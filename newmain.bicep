param paralocation string = resourceGroup().location
param vmuser string 
@secure()
param vmpass string
param logAnalyticsWorkspacename string 
param paraAspSkuCapacity int
param paraAspSkuFamily string
param paraAspSkuName string
param paraAspSkuSize string
param paraAspSkuTier string
param paraFWSubnetIP string
param paraCoreVnetaddressprefix string
param paraHubVnetaddressprefix string
param paraProdVnetaddressprefix string
param paraDevVnetaddressprefix string
param paraRepositoryUrl string
param paraBranch string

var  varSQLPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

var varStPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'

var varKvPrivateDnsZoneName = 'privatelink${environment().suffixes.keyvaultDns}'

// Deafult NSG

module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.1.2' = {
  name: 'DeafultNSG'
  params: {
    // Required parameters
    name: 'deafultnsg'
    // Non-required parameters
    location: paralocation
  }
}

// Hub Vnet

module HubvirtualNetwork 'br/public:avm/res/network/virtual-network:0.1.0' = {
  name: 'Hub-${paralocation}-001' 
  params: {
    // Required parameters
    addressPrefixes: [
      paraHubVnetaddressprefix
    ]
    name: 'hub-vnet-001'
    // Non-required parameters
    location: paralocation
    peerings: [
      {
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'core-vnet-001'
        remoteVirtualNetworkId: CorevirtualNetwork.outputs.resourceId
        useRemoteGateways: false
      }
    ]
    subnets: [
      {
        addressPrefix: '10.10.1.0/24'
        name: 'GatewaySubnet'
      }
      {
        addressPrefix: '10.10.2.0/24'
        name: 'AppgwSubnet'
      }
      {
        addressPrefix: '10.10.4.0/24'
        name: 'AzureBastionSubnet'
        
      }
      {
        addressPrefix: paraFWSubnetIP
        name: 'AzureFirewallSubnet'
      }
    ]
    
  }
}

//Core Vnet
module CorevirtualNetwork 'br/public:avm/res/network/virtual-network:0.1.0' = {
  name: 'Core-${paralocation}-001' 
  params: {
    // Required parameters
    addressPrefixes: [
      paraCoreVnetaddressprefix
    ]
    name: 'core-vnet-001'
    // Non-required parameters
    location: paralocation
    
    subnets: [
      {
        addressPrefix: '10.20.1.0/24'
        name: 'VMSubnet'
      }
      {
        addressPrefix: '10.20.2.0/24'
        name: 'KvSubnet'
        //networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
      }
     
    ]
    
  }
}

// DevVnet
module devSpokeVirtualNetwork 'br/public:avm/res/network/virtual-network:0.1.0' = {
  name: 'dev-${paralocation}-001' 
  params: {
    // Required parameters
    addressPrefixes: [
      paraDevVnetaddressprefix
    ]
    name: 'dev-${paralocation}-001' 
    location: paralocation
    peerings: [
      {
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'Hub-${paralocation}-001' 
        remoteVirtualNetworkId: HubvirtualNetwork.outputs.resourceId
        useRemoteGateways: false
      }
    ]
    subnets: [
      {
        addressPrefix: '10.30.1.0/24'
        name: 'AppSubnet'
      }
      {
        addressPrefix: '10.30.2.0/24'
        name: 'SqlSubnet'
        //networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
      }

      {
        addressPrefix: '10.30.3.0/24'
        name: 'StSubnet'
      }
     
    ]
    
  }
}

// Prod Vnet
module ProdSpokeVirtualNetwork 'br/public:avm/res/network/virtual-network:0.1.0' = {
  name: 'prod-${paralocation}-001' 
  params: {
    // Required parameters
    addressPrefixes: [
      paraProdVnetaddressprefix
    ]
    name: 'prod-${paralocation}-001' 
    location: paralocation
    peerings: [
      {
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'Hub-${paralocation}-00' 
        remoteVirtualNetworkId: HubvirtualNetwork.outputs.resourceId
        useRemoteGateways: false
      }
    ]
    subnets: [
      {
        addressPrefix: '10.31.1.0/24'
        name: 'AppSubnet'
      }
      {
        addressPrefix: '10.31.2.0/24'
        name: 'SqlSubnet'
        //networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
      }

      {
        addressPrefix: '10.31.3.0/24'
        name: 'StSubnet'
      }
     
    ]
    
  }
}

// Bastion host -------------

module bastionHost 'br/public:avm/res/network/bastion-host:0.1.0' = {
  name: 'bas-hub-${paralocation}-001'
  params: {
    // Required parameters
    name: 'bastion-hub'
    vNetId: HubvirtualNetwork.outputs.resourceId
    // Non-required parameters
    location: paralocation
    publicIPAddressObject: {
      allocationMethod: 'Static'

      
      name: 'nbhctmpip001-pip'
      publicIPPrefixResourceId: ''
      
      skuName: 'Standard'
      // skuTier: 'Regional'
     
    }
  }
}


// Vm inside core ------------

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.1.0' = {
  name: 'vm1core001'
  params: {
    // Required parameters
    adminUsername: vmuser
    // encryptionAtHost: false
    imageReference: {
      offer: 'WindowsServer'
      publisher: 'MicrosoftWindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
    }
    name: 'vm1core001'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: CorevirtualNetwork.outputs.subnetResourceIds[0]
          }
        ]
        nicSuffix: '-nic-01'
      }
    ]
    osDisk: {
      caching: 'ReadWrite'
      diskSizeGB: '128'
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Windows'
    vmSize: 'Standard_DS2_v2'
    // Non-required parameters
    adminPassword: vmpass
    location: paralocation

    extensionDependencyAgentConfig: {
      enabled: true
      // tags: {
      //   Environment: 'Non-Prod'
      //   'hidden-title': 'This is visible in the resource name'
      //   Role: 'DeploymentValidation'
      // }
    }

    extensionMonitoringAgentConfig: {
      enabled: true
      monitoringWorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      // tags: {
      //   Environment: 'Non-Prod'
      //   'hidden-title': 'This is visible in the resource name'
      //   Role: 'DeploymentValidation'
      // }
    }
  }
}



module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.3.1' = {
  name: 'logAnalyticsWorkspace'
  params: {
    // Required parameters
    name: logAnalyticsWorkspacename
    // Non-required parameters
    location: paralocation
  }
}

// Vault ---------------

// module vault 'br/public:avm/res/key-vault/vault:0.3.4' = {
//   name: 'kv-encrypt-core-0921'
//   params: {
//     // Required parameters
//     name: 'kv-encrypt-core-0921'
//     sku: 'standard'
//     location: paralocation
    
//     // Non-required parameters
    
    

//     networkAcls: {
//       bypass: 'AzureService'
//       deafultAction: 'Deny'
//       ipRules: [
//         {

//         }
//       ]

//     }
//     enablePurgeProtection: false
//     enableRbacAuthorization: false
    
    
    
    
//     // privateEndpoints: [
//     //   {
        
//     //     privateDnsZoneResourceIds: [
//     //       '<privateDNSResourceId>'
//     //     ]
       
//     //     service: 'vault'
//     //     subnetResourceId: '<subnetResourceId>'
//     //     tags: {
//     //       Environment: 'Non-Prod'
//     //       'hidden-title': 'This is visible in the resource name'
//     //       Role: 'DeploymentValidation'
//     //     }
//     //   }
//     // ]
   
  
//     softDeleteRetentionInDays: 7
    
//   }
// }



// Private DNS Zones ----------

module aspprivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name: 'aspprivateDNSZone'
  params: {
    // Required parameters
    name: 'privatelink.azurewebsites.net'
    // Non-required parameters
    location: 'global'
  }
}

module SQLprivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name: 'SQLprivateDnsZone'
  params: {
    // Required parameters
    name: varSQLPrivateDnsZoneName
    // Non-required parameters
    location: 'global'
  }
}


module StprivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name: 'StprivateDnsZone'
  params: {
    // Required parameters
    name: varStPrivateDnsZoneName
    // Non-required parameters
    location: 'global'
  }
}


module KVprivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name: 'KVprivateDnsZone'
  params: {
    // Required parameters
    name: varKvPrivateDnsZoneName
    // Non-required parameters
    location: 'global'
  }
}


// ---------- Route Table ----------


// module routeTable 'br/public:avm/res/network/route-table:0.2.1' = {
//   name: 'rtfw'
//   params: {
//     // Required parameters
//     name: 'rt-to-fw'
//     // Non-required parameters
//     location: paralocation
//     routes: [
//       {
//         name: 'default'
//         properties: {
//           addressPrefix: '0.0.0.0/0'
//           nextHopIpAddress: '172.16.0.20'
//           nextHopType: 'VirtualAppliance'
//         }
//       }
//       {
//         name: 'core-to-fw'
//         properties: {
//           addressPrefix: paraCoreVnetaddressprefix
//           nextHopType: 'VirtualAppliance'
//           nextHopIpAddress: paraFWSubnetIP
//         }
//       }

//       {
//         name: 'dev-to-fw'
//         properties: {
//           addressPrefix: paraDevVnetaddressprefix
//           nextHopType: 'VirtualAppliance'
//           nextHopIpAddress: paraFWSubnetIP
//         }
//       }

//       {
//         name: 'prod-to-fw'
//         properties: {
//           addressPrefix: paraProdVnetaddressprefix
//           nextHopType: 'VirtualAppliance'
//           nextHopIpAddress:paraFWSubnetIP
//         }
//       }
//     ]
    
//   }
// }

// ----------------------- PROD SPOKE ----------------
// ---------- App Service Plan ----

module AppServicePlan 'br/public:avm/res/web/serverfarm:0.1.0' = {
  name: 'AppServicePlan'
  params: {
    // Required parameters
    name: 'asp'
    sku: {
      capacity: paraAspSkuCapacity
      family: paraAspSkuFamily
      name: paraAspSkuName
      size: paraAspSkuSize
      tier: paraAspSkuTier
    }
    
    location: paralocation
  }
}

// ---------- App Service ------

module appservice 'br/public:avm/res/web/site:0.2.0' = {
  name: 'AppService'
  params: {
    // Required parameters
    kind: 'app'
    name: 'as-prod-001-ap'
    serverFarmResourceId: AppServicePlan.outputs.resourceId

   
    location: paralocation
    
    
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          aspprivateDnsZone.outputs.resourceId
        ]
        subnetResourceId: ProdSpokeVirtualNetwork.outputs.subnetResourceIds[0]
        
        
      }
    ]
    publicNetworkAccess: 'Disabled'
    
    scmSiteAlsoStopped: true
    siteConfig: {
      alwaysOn: true
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnetcore'
        }
      ]
    }
    
    vnetContentShareEnabled: true
    vnetImagePullEnabled: true
    vnetRouteAllEnabled: true
  }
}

// --------- Source Control ---------

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  
  name: 'as-prod-001-ap/web'
  kind: 'Linux'
  properties: {
    repoUrl: paraRepositoryUrl
    branch: paraBranch
    isManualIntegration: true 
  }
}

// module SourceControl 'ModSourceControl.bicep' ={
//   dependsOn: [
//     appservice
//   ]
//   name: ''
//   params: {
//     paraRepositoryUrl: ''
//     paraBranch: ''
//     parasrcControlParent: appservice.outputs.resourceId

//   }
// }

// --------- SQL Server -------------




// ---------- Storage ACCOUNT ----



// ---------- 
