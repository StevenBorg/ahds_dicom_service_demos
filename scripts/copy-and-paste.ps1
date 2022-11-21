# The following finds all workspaces with the rsnastudent in them and kills them
$foo = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like "*rsnastudent*" } | ForEach-Object {$_.ResourceGroupName}
$foo
$foo | ForEach-Object -ThrottleLimit 40 -Parallel  { Remove-AzResourceGroup -Name $_ -Force }

# The following generates the list of resource groups to create
# It cannot be run in parallel because it behaves weirdly
$students = @()
$wsprefix = "rsnastudent";
$rgprefix = "rsnastudentrg";
$dicomname = "mydicom";
$filepathprefix = "C:\Temp\";
Set-Content -Path C:\Temp\dicomservices.txt -value ""
Clear-Content -Path C:\Temp\dicomservices.txt  
1..35 |  ForEach-Object { 
            $sampleHashtable = @{
                resourcegroup = $rgprefix+$_;
                workspace = $wsprefix+$_;
                dicomname = $dicomname; 
                parameterfn=$filepathprefix+"odl"+$_+".parameters.json";
            }
            $students += $sampleHashtable
            $dicombase = $wsprefix+$_ + "-"+$dicomname
            Add-Content -Path C:\Temp\dicomservices.txt -Value $dicombase
        }
$students

# The following creates the resource groups in parallel, up to 30 at a time
#  This approach locks the command line while it runs, could change to AsJob and get control back
$students | ForEach-Object { #-ThrottleLimit 30 -Parallel { 
    New-AzResourceGroup -Name $_.resourcegroup -Location "East US";
    New-AzResourceGroupDeployment -ResourceGroupName $_.resourcegroup `
     -TemplateFile all-up-standalone.bicep `
     -TemplateParameterFile $_.parameterfn `
     -workspace_name $_.workspace  `
     -dicom_service_name $_.dicomname;  
    Write-Output "Done - " + $_.workspace   
}


# The following creates the resource groups in parallel, up to 30 at a time
#  This approach locks the command line while it runs, could change to AsJob and get control back
$students | ForEach-Object -ThrottleLimit 40 -Parallel { 
    New-AzResourceGroup -Name $_.resourcegroup -Location "East US";
    # New-AzResourceGroupDeployment -ResourceGroupName $_.resourcegroup `
    #  -TemplateFile all-up-standalone.bicep `
    #  -TemplateParameterFile $_.parameterfn `
    #  -workspace_name $_.workspace  `
    #  -dicom_service_name $_.dicomname;  
    Write-Output $_.workspace   
}

# The following creates the resource groups in parallel, up to 30 at a time
#  This approach locks the command line while it runs, could change to AsJob and get control back
$students | ForEach-Object -ThrottleLimit 10 -Parallel { 
    Write-Output "Done - " + $_.workspace   
}
