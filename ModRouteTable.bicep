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
    ]
   
  }
}

output outRT string = rtNextHopToFW.id
