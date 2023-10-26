resource hubvnet 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: 'vnet-hub'
}


resource vnetSpoke 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: 'vnet-dev-spoke'

}

resource vnetSpoke1 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: 'vnet-prod-spoke'

}

resource vnetcore 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: 'vnet-Core'

}


resource peerHubtoDevspoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'peer-hub-to-devspoke'
  parent: hubvnet
  properties: {
    allowVirtualNetworkAccess: true
    peeringState: 'Connected'
    allowForwardedTraffic: true
    remoteVirtualNetwork: {
      id: vnetSpoke.id
      }
  }
}

resource peerDevSpoketoHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'peer-spoke-to-hub'
  parent: vnetSpoke
  properties: {
    allowVirtualNetworkAccess: true
    peeringState: 'Connected'
    allowForwardedTraffic: true
    remoteVirtualNetwork: {
      id: hubvnet.id
    }
  }
}

resource peerHubtoProdSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'peer-hub-to-prodspoke'
  parent: hubvnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peeringState:'Connected'
    remoteVirtualNetwork: {
      id: vnetSpoke1.id
    }
  }
}

resource peerProdSpoketoHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'peer-prodspoke-to-hub'
  parent: vnetSpoke1
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peeringState:'Connected'
    remoteVirtualNetwork: {
      id: hubvnet.id
    }
  }
}

resource peerHubtoCore 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'peer-hub-to-core'
  parent: hubvnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: vnetcore.id
    }
  }
}

resource peerCoretoHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'peer-core-to-hub'
  parent: vnetcore
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: hubvnet.id
    }
  }
}
