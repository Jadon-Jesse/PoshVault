# PoshVault

An experimental module that allows you to easily encrypt, share and decrypt project based secrets with trusted parties.


### Motivation

Many scripts written for business applications generally require some form of credentials or "secrets" (username's, password's, apikey's, etc.) 
to be stored alongside the script itself. The problem is that sometimes developers choose the convenient route and store these secrets as 
plain text strings directly in the script itself or in a series of files. This makes it incredibly easy for bad actors to simply read the secrets.



PoshVault aims to be a simple (slightly more secure than plain text) powershell module for working with secrets that need to be easily stored and distributed within an organization.
It allows you to easily store all of your project's secrets in a single encrypted vault. Which can only be unlocked if you know (and have access to) the location of the vault and it's key. 


## Getting Started


### Prerequisites

```
PowerShell 1.0 is required for this module.
```

### Installing

You can install PoshVault using any one of the following options


##### Option 1: PSGallery

```
Install-Module -Name PoshVault -Force
```

##### Option 2: Github

1. Download the PoshVolt folder and save it in your current working directory
2. Then import the module: ```Import-Module ".\PoshVault\PoshVault.psm1" -Force```


### Examples: Basic Usage



###### Hash table of secrets
```
$secrets = @{
    "username_1" = "danny@gmail.com";
    "password_1" = "Password42@#";
    "username_2" = "someftp@supersafe.com";
    "password_2" = "Dem0Password1234!@#";
    "username_3" = "rusty@ocean.com";
    "password_3" = "Cr45hNBurn";
    "other" = "Random notes";
}
```

> First define your secrets as strings in a hashtable

###### Set vault and key path
``` 
#store the vault and key files in the current directory

$vault = ".\vault"
$vaultkey = ".\xes"
```
> Define the path to store the vault and it's key


###### Lock secrets in vault
``` 
Lock-InVault -VaultPath $vault -VaultKeyPath $vaultkey -VaultSecrets $secrets
```
> Lock the hashtable of plain text secrets (```$secrets```) in the vault (```$vault```) using a key (```$vaultKey```). The key (```$vaultKey```) is generated randomly and used to encrypt the secrets (```$secrets```). Once this is done you can throwaway the initial hashtable of (```$secrets```) as they are now contained inside the vault (```$vault```)


###### Get secrets from vault
``` 
$contents = Get-FromVault -VaultPath $vault -VaultKeyPath $vaultkey
echo $contents
```

> Get back the secrets as a hashtable for a given vault (```$vault```) and it's corresponding key (```$vaultKey```)


```
PS >
password_2 : Dem0Password1234!@#
username_1 : danny@gmail.com
other      : Random notes
password_3 : Cr45hNBurn
username_2 : someftp@supersafe.com
username_3 : rusty@ocean.com
password_1 : Password42@#
```

#### Limitations
The maximum amount of data that can be stored is 65,536 characters

#### Note
All that is required for a user to unlock a vault's secrets, is that he or she needs to know the location of the vault and it's corresponding key. While this allows for the encrypted secrets to be shared amongst trusted parties, it could be a potential issue for highly secure situations.

Only use this module if you have no better solution for storing secrets! 



