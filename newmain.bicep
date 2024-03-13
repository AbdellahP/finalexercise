param paralocation string = resourceGroup().location
 
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

param vmName string
param firewallRulesName string
param firewallPolicyName string
param fwName string
param recoveryServiceVaultName string

// ---- RandString -------

var RandString=substring(uniqueString(resourceGroup().id),0,3)

// VM ---------
var vmNICIP = '10.20.1.20'
var vmSize = 'Standard_D2S_v3'


// encryptionKV
var CoreEncryptKeyVaultName = 'kv-encrypt-core-${RandString}'
var CoreSecVaultName = 'kv-sec-ap-01'

// sql vars

var prodSQLserverName = 'sql-prod-${paralocation}-001-${RandString}'
var devSQLserverName  = 'sql-dev-${paralocation}-001-${RandString}'
var sqladminUsername = 'userabz'
var sqladminPassword = 'LegendAbz20204!'
var ProdSQLServerSku = 'Basic'
var prodSQLDatabaseName = 'sqldb-prod-${paralocation}-001-${RandString}'
var devSQLDatabaseName = 'sqldb-dev-${paralocation}-001-${RandString}'

// prod st ------
var StAccountName = 'stprod001${RandString}'
var prodStPrivateEndpointName = 'private-endpoint-${StAccountName}'

//---- Firewall----

var AzFwPrivateIP = '10.10.3.4'

// privateDNS Vars

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

// ----- existing KV with pass and user name
resource coreSecretVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: CoreSecVaultName
}

// Vm inside core ------------
module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.1' = {
  name:'VirtualMachineCore'
  params:{
    adminUsername:  coreSecretVault.getSecret('VMUsername')
    adminPassword: coreSecretVault.getSecret('VMAdminPassword')
    computerName: 'coreComputer'
    encryptionAtHost:false
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
    }
    name: vmName
    location: paralocation
    backupPolicyName: 'DefaultPolicy'
    backupVaultName: recoveryServiceVaults.outputs.name
    backupVaultResourceGroup: recoveryServiceVaults.outputs.resourceGroupName
    nicConfigurations: [
      {
        deleteOption: 'Delete'
        ipConfigurations: [
          {
            name: 'ipconfig'
            privateIPAllocationMethod: 'Static' 
            privateIPAddress: vmNICIP
            subnetResourceId: CorevirtualNetwork.outputs.subnetResourceIds[0]
          }
        ]
        nicSuffix: '-nic-01'
      }
    ]
    osDisk: {
      name: 'name'
      caching: 'ReadWrite'
      diskSizeGB: '128'
      createOption: 'FromImage'
      managedDisk:{
        storageAccountType:'Standard_LRS'
      }
    }
    osType: 'Windows'
    vmSize: vmSize
    extensionAzureDiskEncryptionConfig: {
      enabled: true
      settings: {
        EncryptionOperation: 'EnableEncryption'
        KeyVaultURL: encryptionKeyVault.outputs.uri
        KeyVaultResourceId: encryptionKeyVault.outputs.resourceId
        VolumeType: 'All'
        ResizeOSDisk: false
      }
    }
    extensionAntiMalwareConfig: {
      enabled: true
      settings: {
        AntimalwareEnabled: 'true'
        RealtimeProtectionEnabled: 'true'
      }
    
    }
    extensionDependencyAgentConfig: {
      enabled: true
     
    }
    extensionMonitoringAgentConfig: {
      enabled: true
      monitoringWorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId 
      
    }
  }
}

module encryptionKeyVault 'br/public:avm/res/key-vault/vault:0.3.4' = {
  name:'encryptionKeyVaultDeployment'
  params:{
    name: CoreEncryptKeyVaultName
    location: paralocation
    enableRbacAuthorization: false
    enableVaultForDeployment:true
    enableVaultForDiskEncryption:true
    enableVaultForTemplateDeployment:true
    networkAcls:{
      defaultAction:'Allow'
      bypass:'AzureServices'
    }
    sku:'standard'
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          KVprivateDnsZone.outputs.resourceId
        ]
        service: 'vault'
        subnetResourceId:  CorevirtualNetwork.outputs.subnetResourceIds[1]
        
      }
    ]
  }
}

//RSV
module recoveryServiceVaults './ResourceModules/modules/recovery-services/vault/main.bicep' ={
  //'br:bicep/modules/recovery-services.vault:1.0.0' = { //CARML
  name:recoveryServiceVaultName
  params: {
    name:recoveryServiceVaultName
    location:paralocation
  
    publicNetworkAccess:'Disabled'
  }
}
// module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.1.0' = {
  // name: 'vm1core001'
  // params: {
  //   // Required parameters
  //   adminUsername: vmuser
  //   // encryptionAtHost: false
  //   imageReference: {
  //     offer: 'WindowsServer'
  //     publisher: 'MicrosoftWindowsServer'
  //     sku: '2022-datacenter-azure-edition'
  //     version: 'latest'
  //   }
  //   name: 'vm1core001'
  //   nicConfigurations: [
  //     {
  //       ipConfigurations: [
  //         {
  //           name: 'ipconfig01'
  //           subnetResourceId: CorevirtualNetwork.outputs.subnetResourceIds[0]
  //         }
  //       ]
  //       nicSuffix: '-nic-01'
  //     }
  //   ]
  //   osDisk: {
  //     caching: 'ReadWrite'
  //     diskSizeGB: '128'
  //     managedDisk: {
  //       storageAccountType: 'Standard_LRS'
  //     }
  //   }
  //   osType: 'Windows'
  //   vmSize: 'Standard_DS2_v2'

  //   extensionAntiMalwareConfig: {
  //     enabled: true
  //     settings: {
  //       AntimalwareEnabled: 'true'
  //       RealtimeProtectionEnabled: 'true'
  //     }
  //   // Non-required parameters
  //   adminPassword: vmpass
  //   location: paralocation

  //   extensionDependencyAgentConfig: {
  //     enabled: true
     
  //   }

  //   extensionMonitoringAgentConfig: {
  //     enabled: true
  //     monitoringWorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      
  //   }
//   }
// }



module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.3.1' = {
  name: 'logAnalyticsWorkspace'
  params: {
    // Required parameters
    name: logAnalyticsWorkspacename
    // Non-required parameters
    location: paralocation
  }
}



// --------------- firewall policy ------
module firewallPolicy 'br/public:avm/res/network/firewall-policy:0.1.0' = {
  name:'firewallPolicyDeployment'
  params:{
    name: firewallPolicyName
    location: paralocation
    ruleCollectionGroups: [
      {
        name: firewallRulesName
        priority: 200
        ruleCollections: [
          {
            action: {
              type: 'Allow'
            }
            name: 'allowAllRule'
            priority: 1100
            ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
            rules: [
              {
                name:'Rule1'
                ruleType:'NetworkRule'
                ipProtocols:['Any']
                sourceAddresses:['*']
                destinationAddresses:['*']
                destinationPorts:['*']
              }
            ]
          }
        ]
      }
    ]
  }
}

module azureFirewall './ResourceModules/modules/network/azure-firewall/main.bicep' = {
  name: 'firewallDeployment'
  params: {
    // Required parameters
    name: fwName
    // Non-required parameters
    location: paralocation
    hubIPAddresses:{
      privateIPAddress: AzFwPrivateIP
    }
    publicIPAddressObject: {
      name: 'pip-fw-hub-${paralocation}-001'
      publicIPAllocationMethod: 'Static'
      skuName: 'Standard'
    }
   
    vNetId: HubvirtualNetwork.outputs.resourceId
    firewallPolicyId:firewallPolicy.outputs.resourceId
    diagnosticSettings: [
      {
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId  
      }
    ]
  }
}

// Private DNS Zones ----------

module asprivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name: 'asprivateDNSZone'
  params: {
    // Required parameters
    name: 'privatelink.azurewebsites.net'
    // Non-required parameters
    location: 'global'
    virtualNetworkLinks: [
      {
        name: 'link-core'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: CorevirtualNetwork.outputs.resourceId
      }
      {
        name: 'link-dev'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: devSpokeVirtualNetwork.outputs.resourceId
      }
      {
        name: 'link-hub'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: HubvirtualNetwork.outputs.resourceId
      }
      {
        name: 'link-prod'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: ProdSpokeVirtualNetwork.outputs.resourceId
      }
    ]
  }
}

module SQLprivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name: 'SQLprivateDnsZone'
  params: {
    // Required parameters
    name: varSQLPrivateDnsZoneName
    // Non-required parameters
    location: 'global'
    virtualNetworkLinks: [
      {
        name: 'link-core'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: CorevirtualNetwork.outputs.resourceId
      }
      {
        name: 'link-dev'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: devSpokeVirtualNetwork.outputs.resourceId
      }
      {
        name: 'link-hub'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: HubvirtualNetwork.outputs.resourceId
      }
      {
        name: 'link-prod'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: ProdSpokeVirtualNetwork.outputs.resourceId
      }
    ]
  }
}


module StprivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name: 'StprivateDnsZone'
  params: {
    // Required parameters
    name: varStPrivateDnsZoneName
    // Non-required parameters
    location: 'global'
    virtualNetworkLinks: [
      {
        name: 'link-core'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: CorevirtualNetwork.outputs.resourceId
      }
      {
        name: 'link-hub'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: HubvirtualNetwork.outputs.resourceId
      }
      {
        name: 'link-prod'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: ProdSpokeVirtualNetwork.outputs.resourceId
      }
    ]
  }
}


module KVprivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name: 'KVprivateDnsZone'
  params: {
    // Required parameters
    name: varKvPrivateDnsZoneName
    // Non-required parameters
    location: 'global'

    virtualNetworkLinks: [
      {
        name: 'link-core'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: CorevirtualNetwork.outputs.resourceId
      }
      {
        name: 'link-hub'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: HubvirtualNetwork.outputs.resourceId
      }
      {
        name: 'link-prod'
        location: 'global'
        registrationEnabled: false
        virtualNetworkResourceId: ProdSpokeVirtualNetwork.outputs.resourceId
      }
    ]
  }
}


// ---------- Route Table ----------


module routeTable 'br/public:avm/res/network/route-table:0.2.1' = {
  name: 'rtfw'
  params: {
    // Required parameters
    name: 'rt-${paralocation}-001'
    // Non-required parameters
    location: paralocation
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: '172.16.0.20'
          nextHopType: 'VirtualAppliance'
        }
      }
      {
        name: 'core-to-fw'
        properties: {
          addressPrefix: paraCoreVnetaddressprefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: paraFWSubnetIP
        }
      }

      {
        name: 'dev-to-fw'
        properties: {
          addressPrefix: paraDevVnetaddressprefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: paraFWSubnetIP
        }
      }

      {
        name: 'prod-to-fw'
        properties: {
          addressPrefix: paraProdVnetaddressprefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress:paraFWSubnetIP
        }
      }
    ]
    
  }
}


// ---- applicationInsights -----------
module applicationInsights 'br/public:avm/res/insights/component:0.1.2' = {
  name:'AppInsightsDeployment'
  params:{
    name:'${paralocation}-aSInsights'
    location: paralocation
    workspaceResourceId:logAnalyticsWorkspace.outputs.resourceId 
    kind:'web'
    applicationType: 'web'
  }
}

// ----------------------- PROD SPOKE ----------------

// ---------- Prod App Service Plan ----

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
    reserved: true
    location: paralocation
    kind: 'Linux'
  }
}

// ---------- Prod App Service ------

module appservice 'br/public:avm/res/web/site:0.2.0' = {
  name: 'AppService'
  params: {
    // Required parameters
    kind: 'app'
    name: 'as-prod-001-ap'
    serverFarmResourceId: AppServicePlan.outputs.resourceId
    diagnosticSettings: [
      {
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId 
      }
    ]
    appInsightResourceId: ''

    location: paralocation
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          asprivateDnsZone.outputs.resourceId
        ]
        subnetResourceId: ProdSpokeVirtualNetwork.outputs.subnetResourceIds[0]
        
        
      }
    ]
    publicNetworkAccess: 'Disabled'
    
    scmSiteAlsoStopped: true
    siteConfig: {
      linuxFxVersion:'DOTNETCORE|7.0'
      appSettings:[
        {
          name:'APPINSIGHTS_INSTRUMENTATIONKEY'
          value:applicationInsights.outputs.instrumentationKey
        }
        
        {
          name:'ApplicationInsightsAgent_EXTENSION_VERSION'
          value:'~3'
        }
        {
          name:'XDT_MicrosoftApplicationInsights_Mode'
          value:'default'
        }
      ]
      alwaysOn:true
    }
  }
}

// --------- Source Control ---------


module SourceControl 'ModSourceControl.bicep' = {
  dependsOn: [
    appservice
  ]
  name: 'sourceControl'
  params: {
    paraRepositoryUrl: paraRepositoryUrl
    paraBranch: paraBranch
    paraisManualIntegration: true
  }
}

// --------- Prod SQL Server -------------

module sqlServer 'br/public:avm/res/sql/server:0.1.5' =  {
  name:'prodSQLServer'
  params:{
    name: prodSQLserverName
    administratorLogin: sqladminUsername
    administratorLoginPassword:sqladminPassword
    location: paralocation
    databases: [
      {
        skuName: ProdSQLServerSku
        skuTier: ProdSQLServerSku
        name:  prodSQLDatabaseName 
        maxSizeBytes:2147483648 
      }
    ]
    privateEndpoints: [
      {
        name: 'private-endpoint-prodSQLServer}' 
        privateDnsZoneResourceIds: [
          SQLprivateDnsZone.outputs.resourceId
        ]
        service: 'sqlServer'
        subnetResourceId: ProdSpokeVirtualNetwork.outputs.subnetResourceIds[1] 
        customNetworkInterfaceName : 'pip-${prodSQLserverName}'
      }
    ]
  }
}


// ---------- Prod Storage ACCOUNT ----

module prodstorageAccount 'br/public:avm/res/storage/storage-account:0.5.0' = {
  name: 'prodstorageAccountDeployment'
  params: {
    name: StAccountName
    skuName:'Standard_LRS'
    kind:'StorageV2'
    location: paralocation
    privateEndpoints: [
      {
        name:prodStPrivateEndpointName
        privateDnsZoneResourceIds: [
          StprivateDnsZone.outputs.resourceId
        ]
        service: 'blob'
        subnetResourceId: ProdSpokeVirtualNetwork.outputs.subnetResourceIds[2]
        customNetworkInterfaceName :'pip-${StAccountName}'
      }
    ]
  }
}

// ----------------------- DEV SPOKE ----------------

// ---------- Dev App Service Plan ----

module DevAppServicePlan 'br/public:avm/res/web/serverfarm:0.1.0' = {
  name: 'devAppServicePlan'
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
    reserved: true
    location: paralocation
    kind: 'Linux'
  }
}

// ---------- Dev App Service ------

module devappservice 'br/public:avm/res/web/site:0.2.0' = {
  name: 'devAppService'
  params: {
    // Required parameters
    kind: 'app'
    name: 'as-dev-001-ap'
    serverFarmResourceId: DevAppServicePlan.outputs.resourceId
    diagnosticSettings: [
      {
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId 
      }
    ]
    appInsightResourceId: ''

    location: paralocation
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          asprivateDnsZone.outputs.resourceId
        ]
        subnetResourceId: devSpokeVirtualNetwork.outputs.subnetResourceIds[0]
        
        
      }
    ]
    publicNetworkAccess: 'Disabled'
    
    scmSiteAlsoStopped: true
    siteConfig: {
      linuxFxVersion:'DOTNETCORE|7.0'
      appSettings:[
        {
          name:'APPINSIGHTS_INSTRUMENTATIONKEY'
          value:applicationInsights.outputs.instrumentationKey
        }
        
        {
          name:'ApplicationInsightsAgent_EXTENSION_VERSION'
          value:'~3'
        }
        {
          name:'XDT_MicrosoftApplicationInsights_Mode'
          value:'default'
        }
      ]
      alwaysOn:true
    }
  }
}


module DevSourceControl 'ModSourceControl.bicep' = {
  dependsOn: [
    appservice
  ]
  name: 'devsourceControl'
  params: {
    paraRepositoryUrl: paraRepositoryUrl
    paraBranch: paraBranch
    paraisManualIntegration: true
  }
}

// --------- SQL Server -------------

module devsqlServer 'br/public:avm/res/sql/server:0.1.5' =  {
  name:'devSQLServer'
  params:{
    name: devSQLserverName
    administratorLogin: sqladminUsername
    administratorLoginPassword:sqladminPassword
    location: paralocation
    databases: [
      {
        skuName: ProdSQLServerSku
        skuTier: ProdSQLServerSku
        name:  devSQLDatabaseName 
        maxSizeBytes:2147483648 
      }
    ]
    privateEndpoints: [
      {
        name: 'private-endpoint-prodSQLServer}' 
        privateDnsZoneResourceIds: [
          SQLprivateDnsZone.outputs.resourceId
        ]
        service: 'sqlServer'
        subnetResourceId: ProdSpokeVirtualNetwork.outputs.subnetResourceIds[1] 
        customNetworkInterfaceName : 'pip-${prodSQLserverName}'
      }
    ]
  }
}


// ---------- Storage ACCOUNT ----

module storageAccount 'br/public:avm/res/storage/storage-account:0.5.0' = {
  name: 'storageAccountDeployment'
  params: {
    name: StAccountName
    skuName:'Standard_LRS'
    kind:'StorageV2'
    location: paralocation
    privateEndpoints: [
      {
        name:prodStPrivateEndpointName
        privateDnsZoneResourceIds: [
          StprivateDnsZone.outputs.resourceId
        ]
        service: 'blob'
        subnetResourceId: ProdSpokeVirtualNetwork.outputs.subnetResourceIds[2]
        customNetworkInterfaceName :'pip-${StAccountName}'
      }
    ]
  }
}

// ---------- 

