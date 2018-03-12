[Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")

# SSAS server name variable
$SSASServerName = "zagros"
$SSASDatabase = "Appeal_final"
# Try to connect to the SSAS server
$SSASServer = New-Object Microsoft.AnalysisServices.Server
$SSASServer.Connect($SSASServerName)

# Object to store the result
$Result = @()



    # Get the roles available within the SSAS database and loop thru each of them
    foreach ($Role in $SSASDatabase.Roles)
    {
        # Get the members within the role and loop thru each one of them
        foreach ($UserName in $Role.Members)
        {
            # Create a new object that would store the database name, role name and member user name
            $ItemResult = New-Object System.Object
            $ItemResult | Add-Member -type NoteProperty -name DatabaseName -value $SSASDatabase
            $ItemResult | Add-Member -type NoteProperty -name RoleName -value $Role.Name
            $ItemResult | Add-Member -type NoteProperty -name UserName -value $UserName.Name

            # Put the item result and append it to the result object
            $Result +=$ItemResult
        }
    }


$Result | Select DatabaseName, RoleName, UserName | format-table -auto -wrap | Out-String