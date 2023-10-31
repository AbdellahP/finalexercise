param  paralocation string
param paraAFWipAddress string

resource rtNextHopToFW 'Microsoft.Network/routeTables@2019-11-01' = {
  name: 'rt-to-fw'
  location: paralocation
  properties: {
    routes: [
      {
        name: 'resource-nexthop-to-fw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: paraAFWipAddress
        }
      }

      {
        name: 'core-route'
        properties: {
          addressPrefix: '10.20.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: paraAFWipAddress
        }
      }

      {
        name: 'devspoke-route'
        properties: {
          addressPrefix: '10.30.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: paraAFWipAddress
        }
      }

      {
        name: 'prodspoke-route'
        properties: {
          addressPrefix: '10.31.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: paraAFWipAddress
        }
      }
    ]
   
  }
}

resource RTTags 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  scope: rtNextHopToFW
  properties: {
    tags: {
      Owner: 'Abdellah'
     
      
    }
  }
}

output outRT string = rtNextHopToFW.id
