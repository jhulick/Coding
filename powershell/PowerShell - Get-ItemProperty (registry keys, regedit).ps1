
#
#	Get-ItemProperty
#		|
#		|--> Example: Check registry "HKEY_CURRENT_USER:\" for user-specific "Path" environment variables 
#		|--> Note: Powershell's built-in environment variable $Env:Path is a combination of system & user-specific environment-variables)
#

Get-ItemProperty -Path HKCU:\Environment -Name Path

# 
# Set-ItemProperty -Path ($EachRegEdit.Path) -Name ($EachProp.Name) -Value ($EachProp.Value);
# 
# New-ItemProperty -Path ($EachRegEdit.Path) -Name ($EachProp.Name) -PropertyType ($EachProp.Type) -Value ($EachProp.Value);
# 