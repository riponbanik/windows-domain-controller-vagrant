$ErrorActionPreference = 'Stop'

$domain = 'example.com'
$usersAdPath = 'CN=Users,DC=example,DC=com'
$password = ConvertTo-SecureString -AsPlainText 'HeyH0Password' -Force


# disable all user accounts, except the ones defined here.
$enabledAccounts = @(
    # NB vagrant only works when this account is enabled.
    'vagrant',
    'Administrator'
)
Get-ADUser -Filter {Enabled -eq $true} `
    | Where-Object {$enabledAccounts -notcontains $_.Name} `
    | Disable-ADAccount


# set the Administrator password.
# NB this is also an Domain Administrator account.
Set-ADAccountPassword `
    -Identity "CN=Administrator,$usersAdPath" `
    -Reset `
    -NewPassword $password
Set-ADUser `
    -Identity "CN=Administrator,$usersAdPath" `
    -PasswordNeverExpires $true


# add John Doe.
$name = 'john.doe'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'John' `
    -Surname 'Doe' `
    -DisplayName 'John Doe' `
    -AccountPassword $password `
    -Enabled $true `
    -PasswordNeverExpires $true
# we can also set properties.
Set-ADUser `
    -Identity "CN=$name,$usersAdPath" `
    -HomePage "https://$domain/~$name"
# add user to the Domain Admins group.
Add-ADGroupMember `
    -Identity 'Domain Admins' `
    -Member "CN=$name,$usersAdPath"


# add Jane Doe.
$name = 'jane.doe'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'Jane' `
    -Surname 'Doe' `
    -DisplayName 'Jane Doe' `
    -AccountPassword $password `
    -Enabled $true `
    -PasswordNeverExpires $true


echo 'john.doe Group Membership'
Get-ADPrincipalGroupMembership -Identity 'john.doe' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'vagrant Group Membership'
Get-ADPrincipalGroupMembership -Identity 'vagrant' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000


echo 'Domain Administrators'
Get-ADGroupMember `
    -Identity 'Domain Admins' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000


echo 'Enabled Domain User Accounts'
Get-ADUser -Filter {Enabled -eq $true} `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000