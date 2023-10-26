// DNS ZONE MODULE

//Parameters

param paraASPPrivateDnsZoneName string
param paraSQLPrivateDnsZoneName string
param paraStPrivateDnsZoneName string
param paraKVPrivateDnsZoneName string

//----------- App Service DNS zone ---------------------

resource aspPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: paraASPPrivateDnsZoneName 
  location: 'global'
  properties: {
    
  }
  
}


// ---------- Sql database DNS zone -------------------

resource SQLprivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: paraSQLPrivateDnsZoneName
  location: 'global'
  properties: {
    
  }
  
}

//----------- Storage account DNS zone ------------------

resource StprivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: paraStPrivateDnsZoneName
  location: 'global'
  properties: {
    
  }
  
}

//--------------------------------

resource KVprivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: paraKVPrivateDnsZoneName
  location: 'global'
  properties: {
    
  }
  
}


output outaspPrivateDnsZoneName string = aspPrivateDnsZone.name
output outSQLprivateDnsZoneName string = SQLprivateDnsZone.name
output outStprivateDnsZoneName string = StprivateDnsZone.name
output outKVprivateDnsZoneName string = KVprivateDnsZone.name

output outaspPrivateDnsZoneID string = aspPrivateDnsZone.id
output outSQLprivateDnsZoneID string = SQLprivateDnsZone.id
output outStprivateDnsZoneID string = StprivateDnsZone.id
output outKVprivateDnsZoneID string = KVprivateDnsZone.id

