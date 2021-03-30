$VerbosePreference = "Continue"

$shares = $null
$computers = (Get-ADComputer -Filter{name -like '*'}).Name 

$results = @()

foreach($computer in $computers)
{
    Write-Verbose "Computer: $computer"   

    try{
        #computer accessible
        if (Test-Connection $computer -Count 1 -Quiet)
        {
            # get shares
            $shares = (net view $computer /all | Select-String -Pattern '.*(?=\s*Disk)').Matches.Value

            # If shares returned
            If($shares){
                # Enumerate shares and test for access
                foreach ($share in $shares) 
                {     
                    $share = $share.trim()
                    $result = "" | Select-Object Computer, Share, Path, AccessResult
                    $result.Computer = $computer
                    $result.Share = $share
                    $result.AccessResult =(Test-Path \\$computer\$share\*)
                    $result.Path = $("\\$computer\$share")
                    
                    $results += $result
                    $result
                }
            }
        }
    }
    catch{#swallow errors for now}
}
}
$results | Where-Object{$_.AccessResult -eq "True"} |  Out-GridView