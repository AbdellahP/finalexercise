param paralocation string = resourceGroup().location
 
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

param logAnalyticsWorkspaceName string
var vLogAnalyticsWorkspaceName = '${logAnalyticsWorkspaceName}${Rand}' 

param vmName string
param firewallRulesName string
param firewallPolicyName string
param fwName string
param recoveryServiceVaultName string

param VPNGatewayType string
param VPNGWName string
param  VPNGWSkuName string
param  VPNGatewayPIPName string

param AppGatewayName string
param AppGatewayPIPName string

// ---- RandString -------

var Rand=substring(uniqueString(resourceGroup().id),0,4)

// VM ---------
var vmNICIP = '10.20.1.20'
var vmSize = 'Standard_D2S_v3'


// encryptionKV
var CoreEncryptKeyVaultName = 'kv-encrypt-core-001-${Rand}'
var CoreSecVaultName = 'kv-sec-ap-1'

// sql var

var prodSQLserverName = 'sql-prod-${paralocation}-001-${Rand}'
var devSQLserverName  = 'sql-dev-${paralocation}-001-${Rand}'
var sqladminUsername = 'userabz'
var sqladminPassword = 'LegendAbz20204!'
var ProdSQLServerSku = 'Basic'
var prodSQLDatabaseName = 'sqldb-prod-${paralocation}-001-${Rand}'
var devSQLDatabaseName = 'sqldb-dev-${paralocation}-001-${Rand}'

// prod st ------
var StAccountName = 'stprod001${Rand}'
var prodStPrivateEndpointName = 'private-endpoint-${StAccountName}'

// Dev St ------

var devStAccountName = 'stdev001${Rand}'
var devStPrivateEndPointName = 'private-endpoint-${devStAccountName}'

//---- Firewall----

var AzFwPrivateIP = '10.10.3.4'

// privateDNS Vars

var  varSQLPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

var varStPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'

var varKvPrivateDnsZoneName = 'privatelink${environment().suffixes.keyvaultDns}'

// VAR APPGW

var vAppGwId = resourceId('Microsoft.Network/applicationGateways',AppGatewayName)

var prodOrDev =[0,1]

// Hub Vnet

module HubvirtualNetwork 'br/public:avm/res/network/virtual-network:0.1.1' = {
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
module CorevirtualNetwork 'br/public:avm/res/network/virtual-network:0.1.1' = {
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
module devSpokeVirtualNetwork 'br/public:avm/res/network/virtual-network:0.1.1' = {
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
module ProdSpokeVirtualNetwork 'br/public:avm/res/network/virtual-network:0.1.1' = {
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



//-------------- Deafult NSG --------------

module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.1.2' = {
  name: 'DeafultNSG'
  params: {
    // Required parameters
    name: 'deafultnsg'
    // Non-required parameters
    location: paralocation
  }
}

// Bastion host -------------

module bastionHost 'br/public:avm/res/network/bastion-host:0.1.1' = {
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

// ---------- VPN GW -------------------

// module modVirtualNetworkGateway 'br/public:avm/res/network/virtual-network-gateway:0.1.1' = {
//   name: 'VPNGateway'
//   params: {
//     gatewayType: VPNGatewayType
//     name: VPNGWName
//     skuName: VPNGWSkuName
//     vNetResourceId: HubvirtualNetwork.outputs.resourceId
//     location: paralocation
//     gatewayPipName: VPNGatewayPIPName
    
//   }
// }

// ----- existing KV with pass and user name
resource ModcoreSecretVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: CoreSecVaultName
}


// Vm inside core ------------
module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.1' = {
  name:'VirtualMachineCore'
  params:{
    adminUsername:  ModcoreSecretVault.getSecret('VMUsername')
    adminPassword: ModcoreSecretVault.getSecret('VMAdminPassword')
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
    enableAutomaticUpdates: true
    
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
    patchMode: 'AutomaticByOS'
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

// VM INSIGHTS //

module solution 'br/public:avm/res/operations-management/solution:0.1.2' = {
  name: 'VMInsights'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
    name: 'AzureAutomation'
    product: 'OMSGallery/VMInsights'
    publisher: 'Microsoft'
  }
}


// Datacollection Rules

module MSVMI_PerfandDa_hub_spoke 'br/public:avm/res/insights/data-collection-rule:0.1.2' = {
  name: 'VMInsights-DCR'
  params: {
    location: paralocation
    name: 'MSVMI-PerfandDa-${vmName}'
    description: 'Data collection rule for VM Insights.'
    dataSources: {
      performanceCounters: [
        {
          name: 'VMInsightsPerfCounters'
          streams: [
            'Microsoft-InsightsMetrics'
          ]
          scheduledTransferPeriod: 'PT1M'
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\VmInsights\\DetailedMetrics'
          ]
        }
      ]
      extensions: [
        {
          streams: [
            'Microsoft-ServiceMap'
          ]
          extensionName: 'DependencyAgent'
          extensionSettings: {}
          name: 'DependencyAgentDataSource'
        }
      ]
    }
    dataCollectionEndpointId: dataCollectionEndpoint.outputs.resourceId
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
          name: 'VMInsightsPerf-Logs-Dest'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-InsightsMetrics'
        ]
        destinations: [
          'VMInsightsPerf-Logs-Dest'
        ]
      }
      {
        streams: [
          'Microsoft-ServiceMap'
        ]
        destinations: [
          'VMInsightsPerf-Logs-Dest'
        ]
      }
    ]
    
  }
}


module dataCollectionEndpoint 'br/public:avm/res/insights/data-collection-endpoint:0.1.2' = {
  name: 'DataCollectionEndpoint'
  params: {
    name: 'VMDCE'
    location: paralocation
    kind: 'Windows'
    publicNetworkAccess: 'Enabled'
  }
}

//DCR Association --------------//

module DCRassociation 'ModDCRassociation.bicep' = {
  name: 'configurationAccessEndpoint'
  dependsOn: [ 
    virtualMachine
  ]

  params:{
    vmName: vmName
    DCRId: MSVMI_PerfandDa_hub_spoke.outputs.resourceId
  }
}

module encryptionKeyVault 'br/public:avm/res/key-vault/vault:0.3.4' = {
  name:'encryptionKeyVaultDeployment'
  params:{
    name: CoreEncryptKeyVaultName
    sku:'standard'
    location: paralocation
    enableRbacAuthorization: false
    enableVaultForDeployment:true
    enableVaultForDiskEncryption:true
    enableVaultForTemplateDeployment:true
    enablePurgeProtection: false

    // accessPolicies: [
    //   {
    //     objectId: 'c07cf461-ba5a-4aac-930f-b2346f8fdd3d'
    //     tenantId: 'd4003661-f87e-4237-9a9b-8b9c31ba2467'
    //     permissions: {
    //       keys: [
    //         'get'
    //         'list'
    //         'backup'
    //       ]
    //       secrets: [
    //         'get'
    //         'list'
    //         'backup'
    //       ]
    //     }
    //   }
    // ]
   
    networkAcls:{
      defaultAction:'Allow'
      bypass:'AzureServices'
    }
    
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
//-----------------RSV ---------------------------
module recoveryServiceVaults './ResourceModules/modules/recovery-services/vault/main.bicep' ={
  
  name:recoveryServiceVaultName

  params: {
    name:recoveryServiceVaultName
    location:paralocation
  
    publicNetworkAccess:'Disabled'
  }
}


module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.3.1' = {
  name: 'LogAnalyticsWorkspace'
  params: {
    name: vLogAnalyticsWorkspaceName
    dailyQuotaGb: 10
    dataSources: [
      {
        eventLogName: 'Application'
        eventTypes: [
          {
            eventType: 'Error'
          }
          {
            eventType: 'Warning'
          }
          {
            eventType: 'Information'
          }
        ]
        kind: 'WindowsEvent'
        name: 'applicationEvent'
      }
      {
        counterName: '% Processor Time'
        instanceName: '*'
        intervalSeconds: 60
        kind: 'WindowsPerformanceCounter'
        name: 'windowsPerfCounter1'
        objectName: 'Processor'
      }
      // {
      //   kind: 'IISLogs'
      //   name: 'sampleIISLog1'
      //   state: 'OnPremiseEnabled'
      // }
    ]
    gallerySolutions: [
      {
        name: 'AzureAutomation'
        product: 'OMSGallery'
        publisher: 'Microsoft'
      }
    ]
    location: paralocation
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    useResourcePermissions: true
   
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
          nextHopIpAddress: AzFwPrivateIP
          nextHopType: 'VirtualAppliance'
        }
      }
      {
        name: 'core-to-fw'
        properties: {
          addressPrefix: paraCoreVnetaddressprefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: AzFwPrivateIP
        }
      }

      {
        name: 'dev-to-fw'
        properties: {
          addressPrefix: paraDevVnetaddressprefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: AzFwPrivateIP
        }
      }

      {
        name: 'prod-to-fw'
        properties: {
          addressPrefix: paraProdVnetaddressprefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress:AzFwPrivateIP
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
    workspaceResourceId:logAnalyticsWorkspace.outputs.resourceId 
    location: paralocation
    kind:'web'
    applicationType: 'web'
  }
}

// ----------------------- PROD SPOKE ----------------


// ---------- Prod App Service Plan ----

module ProdAppServicePlan 'br/public:avm/res/web/serverfarm:0.1.0' = {
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

module prodappservice 'br/public:avm/res/web/site:0.2.0' = {
  name: 'ProdAppService'
  params: {
    // Required parameters
    kind: 'app'
    name: 'as-prod-001-ap'
    serverFarmResourceId: ProdAppServicePlan.outputs.resourceId
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
    appInsightResourceId: applicationInsights.outputs.resourceId

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

module modsrcctrl 'ModSourceControl.bicep' =[for spoke in prodOrDev: {
  name: '${(spoke==0) ? 'dev' : 'prod'}-sourceControl' 
  params: {
    paramsrcctrlname: 'web'
    paramAppServiceName: (spoke==0) ? prodappservice.outputs.name : devappservice.outputs.name
  }
}]
// module SourceControl 'ModSourceControl.bicep' = {
//   dependsOn: [
//     appservice
//   ]
//   name: 'sourceControl'
//   params: {
//     srcName: 'as-prod-001-ap/web'
//     paraRepositoryUrl: paraRepositoryUrl
//     paraBranch: paraBranch
//     paraisManualIntegration: true
//   }
// }

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
        name: 'private-endpoint-prodSQLServer' 
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

module prodstorageAccount 'br/public:avm/res/storage/storage-account:0.6.2' = {
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
    appInsightResourceId: applicationInsights.outputs.resourceId

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


// module DevSourceControl 'ModSourceControl.bicep' = {
//   dependsOn: [
//     devappservice
//   ]
//   name: 'devsourceControl'
//   params: {
//     srcName: 'as-dev-001-ap/web'
//     paraRepositoryUrl: paraRepositoryUrl
//     paraBranch: paraBranch
//     paraisManualIntegration: true
//   }
// }

// --------- Dev SQL Server -------------

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
        name: 'private-endpoint-devSQLServer' 
        privateDnsZoneResourceIds: [
          SQLprivateDnsZone.outputs.resourceId
        ]
        service: 'sqlServer'
        subnetResourceId: devSpokeVirtualNetwork.outputs.subnetResourceIds[1] 
        customNetworkInterfaceName : 'pip-${devSQLserverName}'
      }
    ]
  }
}


// ---------- Dev Storage ACCOUNT ----

module storageAccount 'br/public:avm/res/storage/storage-account:0.6.2' = {
  name: 'storageAccountDeployment'
  params: {
    name: devStAccountName
    skuName:'Standard_LRS'
    kind:'StorageV2'
    location: paralocation
    privateEndpoints: [
      {
        name:devStPrivateEndPointName
        privateDnsZoneResourceIds: [
          StprivateDnsZone.outputs.resourceId
        ]
        service: 'blob'
        subnetResourceId: devSpokeVirtualNetwork.outputs.subnetResourceIds[2]
        customNetworkInterfaceName :'pip-${devStAccountName}'
      }
    ]
  }
}

// -------- Application Gateway ----------

module modapplicationGateway './ResourceModules/modules/network/application-gateway/main.bicep' = {
  name: 'ApplicationGateway'
  params: {
    name: AppGatewayName
    location: paralocation
    sku: 'Standard_v2'
    autoscaleMaxCapacity: 3
    autoscaleMinCapacity: 1
    gatewayIPConfigurations: [
      {
        name: 'appgw-ip-configuration'
        properties: {
          subnet: {
            id: HubvirtualNetwork.outputs.subnetResourceIds[1]
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appgw-frontendIP'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: modAppGatewayPIP.outputs.resourceId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appServiceBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: prodappservice.outputs.defaultHostname
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appServiceBackendHttpSetting'
        properties: {
          port: 80
          protocol: 'Http'
          pickHostNameFromBackendAddress:true
        }
      }
    ]
    httpListeners: [
      {
        name: 'httplisteners'
        properties: {
          frontendIPConfiguration: {
            id: '${vAppGwId}/frontendIPConfigurations/appgw-frontendIP'
          }
          frontendPort: {
            id: '${vAppGwId}/frontendPorts/port80'
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'routingrules'
        properties: {
          ruleType: 'Basic'
          priority: 110
          backendAddressPool: {
            id: '${vAppGwId}/backendAddressPools/appServiceBackendPool'
          }
          backendHttpSettings: {
            id: '${vAppGwId}/backendHttpSettingsCollection/appServiceBackendHttpSetting'
          }
          httpListener: {
            id: '${vAppGwId}/httpListeners/httplisteners'
          }
        }
      }
    ]
    
  }
}


module modAppGatewayPIP 'br/public:avm/res/network/public-ip-address:0.2.2' = {
  name:'AppGatewayPip'
  params:{
    name: AppGatewayPIPName
    location:paralocation
    skuName: 'Standard'
    publicIPAllocationMethod:'Static'
  
  }
}
