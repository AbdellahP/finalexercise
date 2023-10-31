param paraVnetCoreName string
param paraVnetHubName string
param paraVnetDevSpokeName string
param paraVnetProdSpokeName string
//---------- ID's for all Vnets ----------
param paraVnetCoreId string
param paraVnetHubId string
param paraVnetDevSpokeId string
param paraVnetProdSpokeId string


param peerHubtoDevspokeName string
param peerDevSpoketoHubName string
param peerHubtoProdSpokeName string
param peerProdSpoketoHubName string
param peerHubtoCoreName string
param peerCoretoHubName string


// resource hubvnet 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
//   name: 'vnet-hub'
// }


// resource vnetSpoke 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
//   name: 'vnet-dev-spoke'

// }

// resource vnetSpoke1 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
//   name: 'vnet-prod-spoke'

// }

// resource vnetcore 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
//   name: 'vnet-Core'

// }


resource peerHubtoDevspoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${paraVnetHubName}/${peerHubtoDevspokeName}'
  properties: {
    allowVirtualNetworkAccess: true
    peeringState: 'Connected'
    allowForwardedTraffic: true
    remoteVirtualNetwork: {
      id: paraVnetDevSpokeId
      }
  }
}

resource peerDevSpoketoHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${paraVnetDevSpokeName}/${peerDevSpoketoHubName}'
  properties: {
    allowVirtualNetworkAccess: true
    peeringState: 'Connected'
    allowForwardedTraffic: true
    remoteVirtualNetwork: {
      id: paraVnetHubId
    }
  }
}

resource peerHubtoProdSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${paraVnetHubName}/${peerHubtoProdSpokeName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peeringState:'Connected'
    remoteVirtualNetwork: {
      id: paraVnetProdSpokeId
    }
  }
}

resource peerProdSpoketoHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${paraVnetProdSpokeName}/${peerProdSpoketoHubName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peeringState:'Connected'
    remoteVirtualNetwork: {
      id: paraVnetHubId
    }
  }
}

resource peerHubtoCore 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${paraVnetHubName}/${peerHubtoCoreName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: paraVnetCoreId
    }
  }
}

resource peerCoretoHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${paraVnetCoreName}/${peerCoretoHubName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: paraVnetHubId
    }
  }
}
