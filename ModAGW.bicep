param pipAppGwName string
param paralocation string
param paraAppGWName string
param paraAGWSubnetId string
param paraProdFqdn string

resource pipAppGw 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: pipAppGwName
  location: paralocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}


resource ApplicationGateway 'Microsoft.Network/applicationGateways@2023-05-01' = {
  name: paraAppGWName
  location: paralocation
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }

    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: paraAGWSubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      { 
        name: 'apgw-FrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pipAppGw.id
          }
        }
      }
    ]
    frontendPorts: [ 
      {
        name: 'port_80'
        properties: {
          port: 80
        }

      }
    ]
    backendAddressPools:[
      {
        name: 'myBackendPool'
        properties:{
          backendAddresses: [
            {
              fqdn: paraProdFqdn
            }
          ]
        }
      }
    ]

    backendHttpSettingsCollection:[
      {
        name: 'myHTTPSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress:  false
          requestTimeout: 20
        }
      }
    ]
    

    httpListeners: [
      {
        name: 'myListener'
        properties: {
          frontendIPConfiguration:{
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', paraAppGWName , 'apgw-FrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', paraAppGWName, 'port_80')
          }

          protocol: 'Http'
          sslCertificate: null
          requireServerNameIndication: false
        
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'myRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener:{
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', paraAppGWName, 'myListener')
          }
          backendAddressPool:{
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', paraAppGWName, 'myBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', paraAppGWName, 'myHTTPSettings')
          }
        }
      }
    ]
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }

  }

}
