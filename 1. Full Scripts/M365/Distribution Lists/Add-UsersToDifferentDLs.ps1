$CSVFile = "C:\Temp\DL-Group-Members.csv"

Try {
    #Connect to Exchange Online
    Connect-ExchangeOnline -ShowBanner:$False

    #Get date from CSV File
    $CSVData = Import-Csv -Path $CSVFile

    #Iterate through each row in the CSV
    ForEach($Row in $CSVData)
    {
        #Get the Distribution Group
        $Group = Get-DistributionGroup -Identity $Row.GroupEmail

        If($Null -ne $Group)
        {
            #Get Exisiting Members of the Group
            $GroupMembers = Get-DistributionGroupMember -Identity $Row.GroupEmail -ResultSize Unlimited | Select-Object -Expand PrimarySmtpAddress

            #Get Users to Add to the Group
            $UsersToAdd =  $Row.Users -split ","

            #Add Each user to the Security group
            ForEach ($User in $UsersToAdd)
            {
                #Check if the group has the member already
                If($GroupMembers -contains $User)
                {
                    Write-host "'$($User)' is already a Member of the Group '$($Group.DisplayName)'" -f Yellow
                }
                Else
                {
                    Add-DistributionGroupMember –Identity $Row.GroupEmail -Member $User
                    Write-host -f Green "Added Member '$User' to the Group '$($Group.DisplayName)'"
                }
            }
        }
        Else
        {
            Write-host "Could not Find Group:"$Row.GroupName
        }
    }
}
Catch {
    write-host -f Red "Error:" $_.Exception.Message
}