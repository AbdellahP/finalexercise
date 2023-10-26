param location string = resourceGroup().location




param KVObjectID string
param KVname string 




var  varSQLPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

var varStPrivateDnsZoneName = 'privatelink${environment().suffixes.storage}'

var varKvPrivateDnsZoneName = 'privatelink${environment().suffixes.keyvaultDns}'





// Module been used to deploy the hub vnet

module Modhubvnet 'ModHub.bicep'= {
  name:'ModhubVnet'
  params: {
    paralocation: location
    // pipVpnGw: 'pipVpnGw'
    // paraVpnGwName: 'vgw-hub${location}-001'

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
    paraAppService: 'as-dev-${location}'
    paraAppServicePlanName: 'asp-dev-${location}'
    paraUserLogin: reskv.getSecret('SqldevUserName')
    paraUserPassword: reskv.getSecret('SqldevUserPassword')
    paraAspPrivateEndpointName: 'private-endpoint-asp-dev'


    paraSQLprivateEndpointName:'private-endpoint-sqlserver-dev'
    sqlServerName: 'sql-dev-${location}-001-${uniqueString(resourceGroup().id)}'
    nsgSQLname: 'nsg-sql-dev'

    parastorageAccountName: 'stdev001${uniqueString(resourceGroup().id)}'
    parastorageAccountType: 'Standard_LRS'
    paraStprivateEndpointName: 'private-endpoint-St-dev'
    nsgStname: 'nsg-St-dev'

    paraRtToFw: ModRouteTable.outputs.outRT
    paraVnetCore: ModVnetCore.outputs.vnetCore
    paraVnetHub: Modhubvnet.outputs.outVnetHub
    paraAspPrivateDnsZoneName: ModDNSZone.outputs.outaspPrivateDnsZoneName
    paraSQLprivateDnsZoneName: ModDNSZone.outputs.outSQLprivateDnsZoneName
    paraStprivateDnsZoneName: ModDNSZone.outputs.outStprivateDnsZoneName
    paraKVprivateDnsZoneName: ModDNSZone.outputs.outKVprivateDnsZoneName
    paraAspPrivateDnsZoneID: ModDNSZone.outputs.outaspPrivateDnsZoneID
    paraSQLprivateDnsZoneID: ModDNSZone.outputs.outSQLprivateDnsZoneID
    paraStprivateDnsZoneID: ModDNSZone.outputs.outStprivateDnsZoneID
    paraKVprivateDnsZoneID: ModDNSZone.outputs.outKVprivateDnsZoneID
    paracontainerName:''
  
    

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
    paraAppService: 'as-prod-${location}'
    paraAppServicePlanName: 'asp-prod-${location}'
    paraUserLogin: reskv.getSecret('SqlprodUserName')
    paraUserPassword: reskv.getSecret('SqlprodUserPassword')
    paraAspPrivateEndpointName:'private-endpoint-asp-prod'
    

    paraSQLprivateEndpointName:'private-endpoint-sqlserver-prod'
    sqlServerName: 'sql-prod-${location}-001-${uniqueString(resourceGroup().id)}'
    nsgSQLname: 'nsg-sql-prod'


    
    parastorageAccountName: 'stprod001${uniqueString(resourceGroup().id)}'
    parastorageAccountType: 'Standard_LRS'
    paraStprivateEndpointName: 'private-endpoint-St-prod'
    nsgStname: 'nsg-St-prod'

    paraRtToFw: ModRouteTable.outputs.outRT
    paraVnetCore: ModVnetCore.outputs.vnetCore
    paraVnetHub: Modhubvnet.outputs.outVnetHub
    paraAspPrivateDnsZoneName: ModDNSZone.outputs.outaspPrivateDnsZoneName
    paraSQLprivateDnsZoneName: ModDNSZone.outputs.outSQLprivateDnsZoneName
    paraStprivateDnsZoneName: ModDNSZone.outputs.outStprivateDnsZoneName
    paraKVprivateDnsZoneName: ModDNSZone.outputs.outKVprivateDnsZoneName
    paraAspPrivateDnsZoneID: ModDNSZone.outputs.outaspPrivateDnsZoneID
    paraSQLprivateDnsZoneID: ModDNSZone.outputs.outSQLprivateDnsZoneID
    paraStprivateDnsZoneID: ModDNSZone.outputs.outStprivateDnsZoneID
    paraKVprivateDnsZoneID: ModDNSZone.outputs.outKVprivateDnsZoneID
    paracontainerName:''
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
    paraAspPrivateDnsZoneName: ModDNSZone.outputs.outaspPrivateDnsZoneName
    paraSQLprivateDnsZoneName: ModDNSZone.outputs.outSQLprivateDnsZoneName
    paraStprivateDnsZoneName: ModDNSZone.outputs.outStprivateDnsZoneName
    paraKVprivateDnsZoneName: ModDNSZone.outputs.outKVprivateDnsZoneName
    

    paraKVprivateDnsZoneID: ModDNSZone.outputs.outKVprivateDnsZoneID

    paraKVprivateEndpointName: 'private-endpoint-KV-core'
    

  }
  
}

module modVnetpeering 'ModVnetpeering.bicep' = {
  name: 'modVnetpeering'
  params:{

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
    paralogAnalyticsName: 'log-core-${location}'
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


















resource reskv 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: KVname

}
