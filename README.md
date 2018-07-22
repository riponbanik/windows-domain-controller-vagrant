
This will crate Windows 2016 Domain Controller using Vagrant and PowerShell.

Windows 2016 base box can be downloaded from [vagrant cloud](https://app.vagrantup.com/jacqinthebox/boxes/windowsserver2016)

This will create an `lab.local` Active Directory Domain Forest. Change the locate, timezone and domain name in the provisioner.

Install the required Vagrant plugins:

```bash
vagrant plugin install vagrant-reload
vagrant plugin install vagrant-windows-sysprep
```

Start by launching the Domain Controller environment:

```bash
vagrant up
```

* Username `Administrator` and password `Passw0rd`.
  * This account is also a Domain Administrator.
* Username `.\vagrant` and password `vagrant`.
  * **NB** you MUST use the **local** `vagrant` account. because the domain also has a `vagrant` account, and that will mess-up the local one...

# Using Remote Service Administration Toolkit (RSAT)
To use RSAT remotely from non-windows join machine and as different user, add the following command in a .bat file and run it

```
@echo off
runas /netonly /user:lab\administrator "mmc /server=dc.lab.local"
```

It will open mmc conosle, from there select the snap-in you would like to use e.g. Active Directory Users and Computers

# Active Directory LDAP

You can use a normal LDAP client for accessing the Active Directory. Replace example.com as per your domain name configured above

It accepts the following _Bind DN_ formats:

* `<userPrincipalName>@<DNS domain>`, e.g. `jane.doe@example.com`
* `<sAMAccountName>@<NETBIOS domain>`, e.g. `jane.doe@EXAMPLE`
* `<NETBIOS domain>\<sAMAccountName>`, e.g. `EXAMPLE\jane.doe`
* `<DN for an entry with a userPassword attribute>`, e.g. `CN=jane.doe,CN=Users,DC=example,DC=com`

**NB** `sAMAccountName` MUST HAVE AT MOST 20 characters.

Some attributes are available in environment variables:

| Attribute        | Environment variable | Example             |
|------------------|----------------------|---------------------|
| `sAMAccountName` | `USERNAME`           | `jane.doe`          |
| `sAMAccountName` | `USERPROFILE`        | `C:\Users\jane.doe` |
| `NETBIOS domain` | `USERDOMAIN`         | `EXAMPLE`           |
| `DNS domain`     | `USERDNSDOMAIN`      | `EXAMPLE.COM`       |

You can list all of the active users using [ldapsearch](http://www.openldap.org/software/man.cgi?query=ldapsearch) as:

```bash
ldapsearch \
  -H ldap://dc.example.com \
  -D jane.doe@example.com \
  -w Passw0rd \
  -x -LLL \
  -b CN=Users,DC=example,DC=com \
  '(&(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))' \
  sAMAccountName userPrincipalName userAccountControl displayName cn mail
```

For TLS, use `-H ldaps://dc.example.com`, after creating the `ldaprc` file with:

```bash
openssl x509 -inform der -in tmp/ExampleEnterpriseRootCA.der -out tmp/ExampleEnterpriseRootCA.pem
cat >ldaprc <<'EOF'
TLS_CACERT tmp/ExampleEnterpriseRootCA.pem
TLS_REQCERT demand
EOF
```

**NB** For TLS troubleshoot use `echo | openssl s_client -connect dc.example.com:636`.
