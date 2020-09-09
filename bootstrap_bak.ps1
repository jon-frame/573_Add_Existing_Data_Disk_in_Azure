 ## Bootstrap to initialise a secondary disk for HoL, and populate with some content 
## Variables for this HoL
$data_disk_size = "10"
$data_disk_file_url = "https://github.com/jon-frame/573_Add_Existing_Data_Disk_in_Azure/raw/master/acg_logo.jpg"
$data_disk_file_name = "acg_logo.jpg"


# Get VM Metadata so we can find and detach the disk
$metadata = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -UseBasicParsing -Uri http://169.254.169.254/metadata/instance?api-version=2020-06-01
$subscription = $metadata.compute.subscriptionId 
$resourcegroup = $metadata.compute.resourceGroupName 
$vmname = $metadata.compute.name 


# Use Azure PS Module to detach the disk so that we can use it with our bastion lab instance
install-packageprovider -name nuget -minimumversion 2.8.5.201 -force
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module -Name Az -AllowClobber


# Connect to Azure
Add-AzAccount -identity
$disk = Get-AzDisk |?{$_.DiskSizeGB -eq $data_disk_size}
$vm = Get-AzVM -Name $vmname -resourceGroupName $resourcegroup
Add-AzVMDataDisk -CreateOption Attach -Lun 0 -VM $vm -ManagedDiskId $disk.Id
$vm = Get-AzVM -Name $vmname -resourceGroupName $resourcegroup
Update-AzVM -VM $vm -ResourceGroupName $resourcegroup
while ((get-azvm).ProvisioningState -eq "Updating")
{
	Write-Host 'waiting for VM to update.' -NoNewline
	Start-Sleep -Seconds 5
}


# Mount the secondary disk (It will be a RAW disk)
$NewPartition = Get-Disk |?{$_.PartitionStyle -eq "RAW"} |  Initialize-Disk -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume

# Write content to disk for later retrieval
Invoke-WebRequest $data_disk_file_url -UseBasicParsing -OutFile ($NewPartition.DriveLetter+"://$data_disk_file_name")

# Dismount the disk from OS
$ExtraDisk = Get-Disk |?{$_.PartitionStyle -eq "GPT"} | Set-Disk -IsOffline $true

# Detach from the VM
$VirtualMachine = Get-AzVM -ResourceGroupName $resourcegroup -Name $vm.Name
Remove-AzVMDataDisk -VM $VirtualMachine -Name $disk.Name
Update-AzVM -VM $VirtualMachine -ResourceGroupName $resourcegroup
while ((get-azvm).ProvisioningState -eq "Updating")
{
	Write-Host 'waiting for VM to update.' -NoNewline
	Start-Sleep -Seconds 5
}

EXIT 0
 
