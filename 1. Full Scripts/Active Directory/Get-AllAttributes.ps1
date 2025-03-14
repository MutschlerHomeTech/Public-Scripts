# Import Active Directory module
Import-Module ActiveDirectory
# Retrieve schema information for all attributes
$attributes = Get-ADObject -SearchBase (Get-ADRootDSE).schemaNamingContext -LDAPFilter "(objectClass=attributeSchema)" -Properties * | Select-Object Name, Description
# Export the attributes to a CSV file
$attributes | Export-Csv -Path "AD_Attributes.csv" -NoTypeInformation