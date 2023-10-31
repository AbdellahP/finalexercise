param location string = resourceGroup().location




param KVObjectID string
param KVname string 
param RandNumber string




var  varSQLPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

var varStPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'

var varKvPrivateDnsZoneName = 'privatelink${environment().suffixes.keyvaultDns}'





// Module been used to deploy the hub vnet

module Modhubvnet 'ModHub.bicep'= {
  name:'ModhubVnet'
  params: {
    paralocation: location
    pipVpnGw: 'pipVpnGw'
    paraVpnGwName: 'vgw-hub${location}-001'

    // paraAppGWName: 'agw-hub${location}-001'
    // pipAppGwName: 'agw-pip'

    paralogAnalytics: ModLogAnalytics.outputs.outLogAnalytics

    paraAspPrivateDnsZoneName: ModDNSZone.outputs.outaspPrivateDnsZoneName
    paraSQLprivateDnsZoneName: ModDNSZone.outputs.outSQLprivateDnsZoneName
    paraStprivateDnsZoneName: ModDNSZone.outputs.outStprivateDnsZoneName
    paraKVprivateDnsZoneName: ModDNSZone.outputs.outKVprivateDnsZoneName
  } 
  
}

module ModDevSpoke 'ModSpoke.bicep' = {
  name:'ModDevSpoke'
  params: {
    paralocation: location
    paraSqlSubnetAddressPrefix: '10.30.2.0/24'
    paraAppSubnetAddressPrefix:'10.30.1.0/24'
    paraStSubnetAddressPrefix: '10.30.3.0/24'
    paraVnetName:'vnet-dev-spoke'
    paraVnetAddressPrefix: '10.30.0.0/16'
    parasku:'B1'
    paraBranch: 'master'
    paraRepositoryUrl: 'https://github.com/Azure-Samples/dotnetcore-docs-hello-world'

    nsgASPname: 'nsg-asp-dev'
    paraAppService: 'as-dev-${location}-${RandNumber}'
    paraAppServicePlanName: 'asp-dev-${location}-${RandNumber}'
    paraUserLogin: reskv.getSecret('SqldevUserName')
    paraUserPassword: reskv.getSecret('SqldevUserPassword')
    paraAspPrivateEndpointName: 'private-endpoint-asp-dev'


    paraSQLprivateEndpointName:'private-endpoint-sqlserver-dev'
    sqlServerName: 'sql-dev-${location}-001-${RandNumber}'
    nsgSQLname: 'nsg-sql-dev'

    parastorageAccountName: 'stdev001${uniqueString(resourceGroup().id)}'
    parastorageAccountType: 'Standard_LRS'
    paraStprivateEndpointName: 'private-endpoint-St-dev'
    nsgStname: 'nsg-St-dev'

    paraRtToFw: ModRouteTable.outputs.outRT
    
    paraAspPrivateDnsZoneName: ModDNSZone.outputs.outaspPrivateDnsZoneName
    paraSQLprivateDnsZoneName: ModDNSZone.outputs.outSQLprivateDnsZoneName
    paraStprivateDnsZoneName: ModDNSZone.outputs.outStprivateDnsZoneName
    paraKVprivateDnsZoneName: ModDNSZone.outputs.outKVprivateDnsZoneName
    paraAspPrivateDnsZoneID: ModDNSZone.outputs.outaspPrivateDnsZoneID
    paraSQLprivateDnsZoneID: ModDNSZone.outputs.outSQLprivateDnsZoneID
    paraStprivateDnsZoneID: ModDNSZone.outputs.outStprivateDnsZoneID
    paraKVprivateDnsZoneID: ModDNSZone.outputs.outKVprivateDnsZoneID
    paracontainerName: 'container1'
    paralogAnalytics: ModLogAnalytics.outputs.outLogAnalytics
    DepartmentNameTag: 'Dev'

    

  }
}

module ModProdSpoke 'ModSpoke.bicep' = {
  name: 'ModProdSpoke'
  params:{
    paraAppSubnetAddressPrefix:'10.31.1.0/24'
    paralocation:location
    paraSqlSubnetAddressPrefix:'10.31.2.0/24'
    paraStSubnetAddressPrefix:'10.31.3.0/24'
    paraVnetName:'vnet-prod-spoke'
    paraVnetAddressPrefix: '10.31.0.0/16'
    parasku: 'B1'
    paraBranch: 'master'
    paraRepositoryUrl: 'https://github.com/Azure-Samples/dotnetcore-docs-hello-world'
    
    nsgASPname: 'nsg-asp-prod'
    paraAppService: 'as-prod-${RandNumber}'
    paraAppServicePlanName: 'asp-prod-${location}-${RandNumber}'
    paraUserLogin: reskv.getSecret('SqlprodUserName')
    paraUserPassword: reskv.getSecret('SqlprodUserPassword')
    paraAspPrivateEndpointName:'private-endpoint-asp-prod'
    

    paraSQLprivateEndpointName:'private-endpoint-sqlserver-prod'
    sqlServerName: 'sql-prod-${location}-001-${RandNumber}'
    nsgSQLname: 'nsg-sql-prod'


    
    parastorageAccountName: 'stprod001${uniqueString(resourceGroup().id)}'
    parastorageAccountType: 'Standard_LRS'
    paraStprivateEndpointName: 'private-endpoint-St-prod'
    nsgStname: 'nsg-St-prod'

    paraRtToFw: ModRouteTable.outputs.outRT

    paraAspPrivateDnsZoneName: ModDNSZone.outputs.outaspPrivateDnsZoneName
    paraSQLprivateDnsZoneName: ModDNSZone.outputs.outSQLprivateDnsZoneName
    paraStprivateDnsZoneName: ModDNSZone.outputs.outStprivateDnsZoneName
    paraKVprivateDnsZoneName: ModDNSZone.outputs.outKVprivateDnsZoneName
    paraAspPrivateDnsZoneID: ModDNSZone.outputs.outaspPrivateDnsZoneID
    paraSQLprivateDnsZoneID: ModDNSZone.outputs.outSQLprivateDnsZoneID
    paraStprivateDnsZoneID: ModDNSZone.outputs.outStprivateDnsZoneID
    paraKVprivateDnsZoneID: ModDNSZone.outputs.outKVprivateDnsZoneID
    paracontainerName:'container1'
    paralogAnalytics: ModLogAnalytics.outputs.outLogAnalytics
    DepartmentNameTag: 'Prod'
  }
  
}

module ModVnetCore 'ModCore.bicep' = {
  name: 'ModVnetCore'
  params:{
    paralocation:location
    paraUser: reskv.getSecret('VmUserName')
    paraUserPass: reskv.getSecret('VMpassword')
    paraRtToFw: ModRouteTable.outputs.outRT
    KVname: KVname
    paravmName: 'vm1core001'
    paraTenantID: subscription().tenantId
    paraKVCoreObjectID: KVObjectID
    storageUri: ModProdSpoke.outputs.outStAccountEP
    paraAspPrivateDnsZoneName: ModDNSZone.outputs.outaspPrivateDnsZoneName
    paraSQLprivateDnsZoneName: ModDNSZone.outputs.outSQLprivateDnsZoneName
    paraStprivateDnsZoneName: ModDNSZone.outputs.outStprivateDnsZoneName
    paraKVprivateDnsZoneName: ModDNSZone.outputs.outKVprivateDnsZoneName
    

    paraKVprivateDnsZoneID: ModDNSZone.outputs.outKVprivateDnsZoneID

    paraKVprivateEndpointName: 'private-endpoint-KV-core'

    paralogAnalytics: ModLogAnalytics.outputs.outLogAnalytics
    
    

  }
  
  
}

module modVnetpeering 'ModVnetpeering.bicep' = {
  name: 'modVnetpeering'
  params:{
    paraVnetCoreName: ModVnetCore.outputs.vnetCoreName
    paraVnetHubName: Modhubvnet.outputs.outVnetHubName
    paraVnetDevSpokeName: ModDevSpoke.outputs.outVnetSpokeName
    paraVnetProdSpokeName: ModProdSpoke.outputs.outVnetSpokeName

    paraVnetCoreId: ModVnetCore.outputs.vnetCoreID
    paraVnetHubId: Modhubvnet.outputs.outVnetHubID
    paraVnetDevSpokeId: ModDevSpoke.outputs.outVnetSpokeID
    paraVnetProdSpokeId: ModProdSpoke.outputs.outVnetSpokeID

    peerHubtoDevspokeName: 'peer-hub-to-devSpoke'
    peerDevSpoketoHubName: 'peer-spoke-to-hub'
    peerHubtoProdSpokeName: 'peer-hub-to-prodspoke'
    peerProdSpoketoHubName: 'peer-prodspoke-to-hub'
    peerHubtoCoreName: 'peer-hub-to-core'
    peerCoretoHubName: 'peer-core-to-hub'
    

  }
  dependsOn: [
    ModDevSpoke
    Modhubvnet
    ModVnetCore
    ModProdSpoke
  ]
  
}

module ModRouteTable 'ModRouteTable.bicep' ={
  name: 'ModRouteTable'
  params: {
    paralocation: location
    paraAFWipAddress: Modhubvnet.outputs.outAFWIp
    
  }
}

module ModLogAnalytics 'ModLogAnalyticsWorkSpace.bicep' = {
  name: 'ModLogAnalytics'
  params: {
    paralocation: location
    paralogAnalyticsName: 'log-core-${location}-001--${uniqueString(resourceGroup().id)}'
  }
}

module ModAGW 'ModAGW.bicep'= {
  name: 'ModAGW'
  params: {
    paralocation: location
    paraAppGWName: 'agw-hub${location}-001'
    pipAppGwName: 'agw-pip'
    paraAGWSubnetId: Modhubvnet.outputs.outAGWSubnet
    paraProdFqdn: ModProdSpoke.outputs.Prodfqdn

  }
  dependsOn: [
    ModProdSpoke
    ModVnetCore
  ]
}

module ModDNSZone 'ModDNSZone.bicep' = {
  name: 'ModDNSZone'
  params: {
    paraASPPrivateDnsZoneName: 'privatelink.azurewebsites.net'
    paraSQLPrivateDnsZoneName: varSQLPrivateDnsZoneName
    paraStPrivateDnsZoneName: varStPrivateDnsZoneName
    paraKVPrivateDnsZoneName: varKvPrivateDnsZoneName
  }
}

module ModRSV 'ModRSV.bicep' = {
  name: 'ModRSV'
  params: { 
    paralocation: location
    paraVaultName: 'rsv-core-${location}-001'
    paraScheduleRunTimes: '2023-10-27T12:30:00Z'
    paraPolicyName: 'DeafultPolicy'
    paraVMName: ModVnetCore.outputs.outVMname
    paraVMId: ModVnetCore.outputs.outVmId

  }
}
















resource reskv 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: KVname

}
