 ## To do:

# Mount the secondary disk (It will be a RAW disk)
$NewPartition = Get-Disk |?{$_.PartitionStyle -eq "RAW"} |  Initialize-Disk -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume

# Write content to disk for later retrieval
Invoke-WebRequest https://github.com/jon-frame/573_Add_Existing_Data_Disk_in_Azure/raw/master/acg_logo.jpg -OutFile ($NewPartition.DriveLetter+"://acg_logo.jpg")

# Dismount the Disk
$ExtraDisk = Get-Disk |?{$_.PartitionStyle -eq "GPT"} | Set-Disk -IsOffline $true

# Get VM Metadata so we can find and detach the disk
$Metadata = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Uri http://169.254.169.254/metadata/instance?api-version=2020-06-01



# Use Azure PS Module to detach the disk so that we can use it with our bastion lab instance
# Successfully exit script



if (1 -eq 1) {
# everything went according to plan

    $LastExitCode = 0

}else {  
# something didn't work right, so the deployment should fail

    $LastExitCode = 1
}

EXIT $LastExitCode
 
