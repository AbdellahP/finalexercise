param paraVaultName string 
param paralocation string
param paraPolicyName string
param paraScheduleRunTimes string
param parargName string = resourceGroup().name
param paraVMName string
param paraVMId string

var protectedContainerName = 'iaasvmcontainer;iaasvmcontainerv2;'
var protectedItemNameVm = 'vm;iaasvmcontainerv2'

// RSV Deploys however throws an error on deployment. 

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2021-03-01' =  {
  name: paraVaultName
  location: paralocation
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2021-03-01' = {
  parent: recoveryServicesVault
  name: paraPolicyName
  location: paralocation
  properties: {
    backupManagementType: 'AzureIaasVM'
    instantRpRetentionRangeInDays: 5
    schedulePolicy: {
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: [ paraScheduleRunTimes ]
      schedulePolicyType: 'SimpleSchedulePolicy'
    }
    retentionPolicy: {
      dailySchedule: {
        retentionTimes:[ paraScheduleRunTimes]
        retentionDuration: {
          count: 104
          durationType: 'Days'
        }
      }
      weeklySchedule: {
        daysOfTheWeek: [
          'Sunday'
          'Wednesday'
          'Friday'
        ]
        retentionTimes: [paraScheduleRunTimes]
        retentionDuration: {
          count: 100
          durationType: 'Weeks'
        }
      }
      monthlySchedule: {
        retentionScheduleFormatType: 'Daily'
        retentionScheduleDaily: {
          daysOfTheMonth: [
            {
              date: 1
              isLast: false
            }
          ]
        }
        retentionTimes: [paraScheduleRunTimes]
        retentionDuration: {
          count: 50
          durationType: 'Months'
        }
      }
      yearlySchedule: {
        retentionScheduleFormatType: 'Daily'
        monthsOfYear: [
          'January'
          'April'
          'September'
        ]
        retentionScheduleDaily: {
          daysOfTheMonth: [
            {
              date: 1
              isLast: false
            }
          ]
        }
        retentionTimes: [paraScheduleRunTimes]
        retentionDuration: {
          count: 10
          durationType: 'Years'
        }
      }
      retentionPolicyType: 'LongTermRetentionPolicy'
    }
    timeZone: 'UTC'
  }
}

resource RSVStorageconfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2023-02-01' = {
  parent: recoveryServicesVault
  name: 'vaultstorageconfig'
  properties: {
    storageModelType: 'GeoRedundant'
    crossRegionRestoreFlag: true

  }
}

resource VmBackUp 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-03-01' =  {
  
  name: '${paraVaultName}/Azure/${protectedContainerName}${protectedItemNameVm}${parargName};${paraVMName}/${protectedItemNameVm};${parargName};${paraVMName}'
  location: paralocation
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: backupPolicy.id
    sourceResourceId: paraVMId
  }
  dependsOn: [
    RSVStorageconfig
  ]
}

