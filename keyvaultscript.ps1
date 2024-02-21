# Parameters for Random Password Generator 


$upperCaseSet=(65..90) | foreach{[char]$_}
$lowerCaseSet=(97..122) | foreach{[char]$_}
$numericset=(48..57) | foreach{[char]$_}
$specialSet=(33,35,36,37,38,42,63) | foreach{[char]$_}

$CharSet=$upperCaseSet+$lowerCaseSet+$numericset+$specialSet
$CharSet1=$upperCaseSet+$lowerCaseSet+$numericset



#----------- Vm -------------
$vmUserName=-join($CharSet1 | Get-Random -Count 15 )
$vmUserPassword=-join($CharSet | Get-Random -Count 15)


#---------------- SQL DEV -----------------------

$sqldevUserName=-join($CharSet1 | Get-Random -Count 15)
$sqldevUserPassword=-join($CharSet | Get-Random -Count 15)


# ---------------- SQL Prod -----------------

$sqlprodUserName=-join($CharSet1 | Get-Random -Count 15)
$sqlprodUserPassword=-join($CharSet | Get-Random -Count 15)


# $location = Get-AzResourceGroup | select-object -ExpandProperty Location


$Random = Get-Random -Minimum 150 -Maximum 2222

$KVName = "kv-secert-core-"+$Random

$resourcegroup = 'rg-abdellah-chohort3'

$location = Get-AzResourceGroup -Name $resourcegroup | select-object -ExpandProperty Location

# $location = Get-AzResourceGroup | select-object -ExpandProperty Location



# $resourcegroup = Get-AzResourceGroup | Select-Object -ExpandProperty ResourceGroupName



$KVObjectID = Get-AzADUser -SignedIn | Select-Object -ExpandProperty Id




New-AzKeyVault -VaultName $KVName -ResourceGroupName $resourcegroup -Location $location -EnabledForTemplateDeployment

#---------- VM Username and password -----------

$secretVmUserName = ConvertTo-SecureString $vmUserName -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $KVName -Name "VmUserName" -SecretValue $secretVmUserName

$secretVmPassword = ConvertTo-SecureString $vmUserPassword -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $KVName -Name "VMpassword" -SecretValue $secretVmPassword


#------------------ Dev Sql User and Pass ---------

$secretSqldevUserName = ConvertTo-SecureString $sqldevUserName -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $KVName -Name "SqldevUserName" -SecretValue $secretSqldevUserName

$secretSqldevPassword = ConvertTo-SecureString $sqldevUserPassword -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $KVName -Name "SqldevUserPassword" -SecretValue $secretSqldevPassword

#------------------ Prod Sql and pass ----------

$secretSqlProdUserName = ConvertTo-SecureString $sqlprodUserName -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $KVName -Name "SqlprodUserName" -SecretValue $secretSqlProdUserName

$secretSqlPordPassword = ConvertTo-SecureString $sqlprodUserPassword -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $KVName -Name "SqlprodUserPassword" -SecretValue $secretSqlPordPassword


#-------------------




#-----------------------Run Bicep file-------------------


new-AzResourceGroupDeployment -ResourceGroupName $resourcegroup -TemplateFile .\main.bicep -KVname $KVname -KVObjectID $KVObjectID -RandNumber $Random














# $resourceGroupName = ""
# $keyVaultName = ""
# $vmAdminPassword = ""
# $sqlAdminPassword = ""

# # Create new Azure Key Vault 

# New-AzKeyVault -VaultName $keyVaultName -resourceGroupName $resourceGroupName -location $resourceGroupName.location

# Set-AzKeyVaultAccessPolicy -resourceGroupName $resourceGroupName -VaultName $keyVaultName
























# function Get-RandomPassword{
#     [cmdletbinding()]
#     param (
#         [Parameter()]
#         [int]$PasswordLength=10,
#         [Parameter()]
#         [bool]$UpperCase=$true,
#         [Parameter()]
#         [bool]$lowerCase=$true,
#         [Parameter()]
#         [bool]$Numeric=$true,
#         [Parameter()]
#         [bool]$Special=$true
#     )
    
#     if($UpperCase){
#         $upperCaseSet=(65..90) | foreach{[char]$_}
#     }

#     if($lowerCase){
#         $lowerCaseSet=(97..122) | foreach{[char]$_}
        
#     }

#     if($Numeric){
#         $numericset=(48..57) | foreach{[char]$_}
        
        
#     }

#     if($Special){
#         $specialSet=(33,35,36,37,38,42,63) | foreach{[char]$_}
        
#     }

#     # $upperCaseSet=$null
#     # $lowerCaseSet=$null
#     # $numericset=$null
#     # $specialSet=$null

#     $CharSet=$upperCaseSet+$lowerCaseSet+$numericset+$specialSet

#     return -join(Get-Random -Count $PasswordLength -InputObject $CharSet)


# }

# Get-RandomPassword
