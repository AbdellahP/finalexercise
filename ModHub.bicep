param paralocation string 
param pipVpnGw string
param paraVpnGwName string
// param paraAppGWName string
// param pipAppGwName string
param paralogAnalytics string

//output parameters for DNS zone name
param paraAspPrivateDnsZoneName string
param paraSQLprivateDnsZoneName string
param paraStprivateDnsZoneName string
param paraKVprivateDnsZoneName string



resource vnethub 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-hub'
  location: paralocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.10.4.0/24'
         
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.10.3.0/24'
        }
      }
      {
        name:'GatewaySubnet'
        properties:{
          addressPrefix: '10.10.1.0/24'
        }
      }
      {
        name:'AppgwSubnet'
        properties:{
          addressPrefix: '10.10.2.0/24'
        }
      }
        
    ]
  }

  resource bastionSubnet 'subnets' existing = {
    name: 'AzureBastionSubnet'
  }

  resource AzureFirewallSubnet 'subnets' existing= {
    name: 'AzureFirewallSubnet'
  }

  resource GatewaySubnet 'subnets' existing = {
    name: 'GatewaySubnet'
  }

  resource AppgwSubnet 'subnets' existing = {
    name: 'AppgwSubnet'
  }
}

//---------------------- Azure Bastion ----------------------

resource pipAzureBastion 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: 'pip-Bastion'
  location: paralocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    publicIPAddressVersion:'IPv4'
    }
}


resource bastionInstance 'Microsoft.Network/bastionHosts@2023-04-01' = {
  name: 'bas-hub-${paralocation}-001'
  location: paralocation
  sku: {
    name:'Basic'
  }
  properties:{
    ipConfigurations: [
      {
        name: 'hub-subnet'
        properties:{
          privateIPAllocationMethod:'Dynamic'
          subnet: {
            id:vnethub::bastionSubnet.id
          }
          publicIPAddress: {
            id: pipAzureBastion.id
        
          }
        }
      }
    ]
  }

}

// ---------------- Firewall ----------------------------------------------

resource pipFirewall 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'pip-Firewall'
  location: paralocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
   
  }
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-04-01' = {
  name:'fw-Policy'
  location: paralocation
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Deny'
    insights: {
      isEnabled: true
      retentionDays: 30
      logAnalyticsResources: {
        defaultWorkspaceId: {
          id: paralogAnalytics
        }
      }
    }
    threatIntelWhitelist: {
      fqdns: [
      ]
      ipAddresses: []
    }
    intrusionDetection: null
    dnsSettings: {
      servers: []
      enableProxy: true
    }

  }

  resource defaultNetworkRuleCollectionGroup 'ruleCollectionGroups@2022-01-01' = {
    name: 'DefaultNetworkRuleCollectionGroup'
    properties: {
      priority: 200
      ruleCollections: [
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Allow-all'
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'all'
              
              ipProtocols: [
                'Any'
              ]
              sourceAddresses: [
                '*'
              ]
              sourceIpGroups: []
              destinationAddresses: [
                '*'
              ]
              destinationIpGroups: []
              destinationFqdns: []
              destinationPorts: [
                '*'
              ]
            }
          ]
        }
      ]
    }
  }

    
  

  // resource defaultApplicationRuleCollectionGroup 'ruleCollectionGroups@2022-01-01' = {
  //   name: 'DefaultApplicationRuleCollectionGroup'
  // }
}

resource firewall 'Microsoft.Network/azureFirewalls@2023-04-01' = {
  name: 'afw-hub-${paralocation}-001'
  location: paralocation
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    firewallPolicy: {
      id:firewallPolicy.id
    }
    ipConfigurations: [
      {
        name:pipFirewall.name
        properties:{
          subnet:{
            id: vnethub::AzureFirewallSubnet.id

          }
          publicIPAddress: {
            id: pipFirewall.id
          }
        }
      }
    ]
  }

}

resource firewallDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diagnostics-firewall'
  scope: firewall
  properties: {
    workspaceId: paralogAnalytics
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [ {
      category: 'AllMetrics'
      enabled: true
    }
    ]
  }
}








// ------------- Hub Gateway Tested and works--------------------


// resource pipVpnGateway 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
//   name: pipVpnGw
//   location: paralocation
//   sku: {
//     name: 'Standard'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Static'
//     idleTimeoutInMinutes: 4
//     publicIPAddressVersion: 'IPv4'
   
//   }
// }

// resource vpnGW 'Microsoft.Network/virtualNetworkGateways@2023-05-01' = {
//   name: paraVpnGwName
//   location: paralocation
//   properties: {
//     sku: {
//       name: 'VpnGw2AZ'
//       tier: 'VpnGw2AZ'

//     }
//     gatewayType: 'Vpn'
//     vpnType: 'RouteBased'
//     vpnGatewayGeneration: 'Generation2'
//     ipConfigurations:[
//       {
//         name: 'deafult'
//         properties: {
//           privateIPAllocationMethod: 'Dynamic'
//           publicIPAddress: {
//             id: pipVpnGateway.id
//           }
//           subnet: {
//             id:vnethub::GatewaySubnet.id
//           }
//         }
//       }
//     ]
//   }
// }



//--------------------- Private DNS zone Links --------------------------------


resource SQLprivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${paraSQLprivateDnsZoneName}/${vnethub.name}SQLDnsZonelink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnethub.id
    }
  }
}

resource StprivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  
  name: '${paraStprivateDnsZoneName}/${vnethub.name}StDnsZoneLink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnethub.id
    }
  }
}

resource aspPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${paraAspPrivateDnsZoneName}/${vnethub.name}aspDnsZoneLink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnethub.id
    }
  }
} 

resource KvPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${paraKVprivateDnsZoneName}/${vnethub.name}KvDnsZoneLink'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:vnethub.id
    }
  }
}

//----------------- Tags----------------

resource BastionTags 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  scope: bastionInstance 
  properties: {
    tags: {
      Owner: 'Abdellah'
   
      
    }
  }
}

resource AFWTags 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  scope: firewall
  properties: {
    tags: {
      Owner: 'Abdellah'
      
      
    }
  }
}




// --------------- Outputs ---------------------------

output outAFWIp string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output outAGWSubnet string = vnethub.properties.subnets[3].id
output outVnetHubID string = vnethub.id
output outVnetHubName string =vnethub.name



