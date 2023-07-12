param( [Parameter(Mandatory=$true)] $JSONFile)

function CreateADGroup(){
    param( [Parameter(Mandatory=$true)] $groupObject )

    $name = $groupObject.name
    New-ADGroup -name $name -GroupScope Global
}

function CreateADUser() {
    param( [Parameter(Mandatory=$true)] $userObject )

    # Extract name from JSON object
    $name = $userObject.name
    $password = $userObject.password

    # Generrate a first init, last name structure for all usernames
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname[0] + $lastname).ToLower();
    $SamAccountName = $username
    $principalname = $username

    #Actually create the AD user object
    New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount

    # Add the user to the group
    foreach($group_name in $userObject.groups) {
        
        try {
            Get-ADGroup -Identity “$group_name”
            Add-ADGroupMember -Identity $group_name -Members $username 
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning “User $name NOT added to group $group_name because it does not exist”
        }
    }

}

$json = (Get-Content $JSONFile | ConvertFrom-Json)

$Global:Domain = $json.domain

foreach ($group in $json.groups ) {
    CreateADGroup $group
}

foreach ($user in $json.users ) {
    CreateADUser $user
}