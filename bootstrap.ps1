## To do:

# Attach the secondary disk and initialise it
# Write content to disk for later retrieval
# Dismount the Disk
# Use Azure PS Module to detach the disk so that we can use it with our bastion lab instance
# Successfully exit script

if (1 = 1) {
# everything went according to plan

    $LastExitCode = 0

}

else{  
# something didn't work right, so the deployment should fail

    $LastExitCode = 1
}

EXIT $LastExitCode
