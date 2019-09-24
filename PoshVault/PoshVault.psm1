Function Lock-InVault {
    <#
    .DESCRIPTION
    Function that generates the vault and the key for the given hashtable of secrets
    Note that we store the contents as a json string.

    .PARAMETER VaultPath
    Path to store the vault file

    .PARAMETER VaultKeyPath
    Path to store the encoded key file which unlocks the vault file

    .PARAMETER VaultSecrets
    Hashtable of key-value pair secrets to be locked in the vault
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Justification="We're not storing the plain text")]
    Param (
        [Parameter(Mandatory=$False, HelpMessage="Enter the path to store the vault")]
        [string]$VaultPath="vault",

        [Parameter(Mandatory=$False, HelpMessage="Enter the path to store the vaults key")]
        [string]$VaultKeyPath="xes",

        [Parameter(Mandatory=$True, HelpMessage="Hashtable of values to lockup")]
        [hashtable]$VaultSecrets
    )


    $jsonSecrets = $VaultSecrets | ConvertTo-Json
    #Ensure we have a string within the max allowed
    #See: https://docs.microsoft.com/en-us/dotnet/api/system.security.securestring.length?view=netframework-4.8
    If ($jsonSecrets.Length -lt 65536){

        $AESKey = New-Object Byte[] 32
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)

        $fileContentEncoded = [System.Convert]::ToBase64String($AESKey)

        Set-Content -Path $VaultKeyPath -Value $fileContentEncoded

        $secureSecrets = ConvertTo-SecureString -String $jsonSecrets -AsPlainText -Force

        $secureSecretsText = ConvertFrom-SecureString -SecureString $secureSecrets -Key $AESKey

        Set-Content -Path $VaultPath -Value $secureSecretsText
    }
    Else{

        Set-Content -Path $VaultKeyPath -Value "Error: Too many secrets. MAX_CHARS ALLOWED = 65536"
        Set-Content -Path $VaultPath -Value "Error: Too many secrets. MAX_CHARS ALLOWED = 65536"
    }



}


Function Get-FromVault {
    <#
    .DESCRIPTION
    Function that takes in a vault and a corresponding key and attempts to unlock the contents
    Returns the contents as a hashtable if sucessful

    .PARAMETER VaultPath
    Path of the vault file to be unlocked

    .PARAMETER VaultKeyPath
    Path to corresponding key whick unlocks the vault
    #>
    Param (
        [Parameter(Mandatory=$False, HelpMessage="Enter the path to the existing vault")]
        [string]$VaultPath="vault",

        [Parameter(Mandatory=$False, HelpMessage="Enter the path to the vaults key")]
        [string]$VaultKeyPath="xes"
    )

    $vaultContents = @{}

    If ((Test-Path -Path $VaultPath) -And (Test-Path -Path $VaultKeyPath)){

        $AESKeyEnc = Get-Content $VaultKeyPath
        $AESKey = [System.Convert]::FromBase64String($AESKeyEnc)

        $rawVault = Get-Content $VaultPath

        $secureVault = ConvertTo-SecureString -String $rawVault -Key $AESKey

        $username = "posh@vault.co.za"

        $credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureVault

        $vaultContents = $credObject.GetNetworkCredential().password | ConvertFrom-Json

        return $vaultContents
    }
    Else{

        return $vaultContents

    }

}