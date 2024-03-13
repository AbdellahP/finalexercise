using 'newmain.bicep' 



param logAnalyticsWorkspacename  = 'logAnalyticsWorkspace'


param paraFWSubnetIP = '10.10.3.0/24'
param paraCoreVnetaddressprefix = '10.20.0.0/16'
param paraHubVnetaddressprefix = '10.10.0.0/16'
param paraProdVnetaddressprefix = '10.31.0.0/16'
param paraDevVnetaddressprefix = '10.30.0.0/16'


// VM
param vmName = 'vm-core-uksouth-001'

// RSV
param recoveryServiceVaultName = 'rsv-core-uksouth-001'

// FIREWALL POLICY and fw
param firewallRulesName = 'fwRules-hub-001'
param firewallPolicyName = 'fwPolicy-hub-001'
param fwName = 'fw-hub-001'

// APP SERVICE PLAN 
param paraAspSkuCapacity = 1
param paraAspSkuFamily = 'B'
param paraAspSkuName = 'B1'
param paraAspSkuSize = 'B1'
param paraAspSkuTier = 'Basic'
param paraBranch = 'master'
param paraRepositoryUrl = 'https://github.com/Azure-Samples/dotnetcore-docs-hello-world'

