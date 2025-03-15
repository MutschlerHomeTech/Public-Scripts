##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Test a Group Managed Service Account (gMSA) on all Domain Controllers.
#
# VERSION  : 1    (Initial release)
##########################################

# This will run on all Domain Controllers. . Replace 'adhealthcheck' with actual gMSA name
Invoke-Command -ComputerName (Get-ADDomainController -Filter *).Name -ScriptBlock {
    $Account = Get-ADServiceAccount -Filter { Name -eq 'adhealthcheck'}
    Install-ADServiceAccount $Account

    # Tests that the GMSA works on the computer
    # Returns $True if tests are OK
    $Test = Test-ADServiceAccount -Identity $Account.Name
    if($Test){
        Write-Output "GMSA test OK on $env:computername"
    }
    else {
        Write-Output "GMSA test FAILED on $env:computername"
    }

}