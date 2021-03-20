$rgName = "myPackerGroup"
$location = "UkSouth"
New-AzResourceGroup -Name $rgName -Location $location

$sp = New-AzADServicePrincipal -DisplayName "PackerSP$(Get-Random)"
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$plainPassword
$sp.ApplicationId