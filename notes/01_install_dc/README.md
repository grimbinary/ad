# 01 Installing the Domain Controller
1. Use `sconfig` to 
    - Change the hostanme 
    - Change the IP address to static
    - Change the DNS server to our own IP address
    
2. Install the ACtive Directory Windows Feature

```shell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

```
Get-NetIPAddress <IP>
Get-DNSClientServerAddress <IP>
```

# Joining the workstation to the domain

```
Add-Computer -Domainname xyz.com -Credential xyz\administrator -Force -Restart
```