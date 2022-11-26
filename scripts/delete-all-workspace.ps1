$foo = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like "*rsnastudent*" } | ForEach-Object {$_.ResourceGroupName}
$foo
$foo | ForEach-Object -ThrottleLimit 10 -Parallel  { Remove-AzResourceGroup -Name $_ -Force }

$foo = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like "*sjbDeleteMe*" } | ForEach-Object {$_.ResourceGroupName}
$foo
$foo | ForEach-Object -ThrottleLimit 30 -Parallel { Remove-AzResourceGroup -Name $_ -Force }


New-AzResourceGroup -Name sjbDeleteMe1 -Location $location;
New-AzResourceGroupDeployment -ResourceGroupName sjbDeleteMe1 `
  -TemplateFile all-up-standalone.bicep `
  -TemplateParameterFile C:\Temp\odl.parameters.json `
  -workspace_name "rsnastudent01" `
  -dicom_service_name "mydicom"





# The following generates the list of resource groups to create
# It cannot be run in parallel because it behaves weirdly
$students = @()
$wsprefix = "rsnastudent";
$rgprefix = "rsnastudentrg";
$dicomname = "mydicom";
$filepathprefix = "C:\Temp\";
1..30 |  ForEach-Object { 
            $sampleHashtable = @{
                resourcegroup = $rgprefix+$_;
                workspace = $wsprefix+$_;
                dicomname = $dicomname; 
                parameterfn=$filepathprefix+"odl"+$_+".parameters.json";
            }
            $students += $sampleHashtable
        }

$students | ForEach-Object -ThrottleLimit 30 -Parallel { 
    Write-Output $_.resourcegroup; 
    Write-Output $_.workspace;
    Write-Output $_.dicomname;
    Write-Output $_.parameterfn;

    #New-AzResourceGroup -Name $resourcegroup -Location $location;
    #New-AzResourceGroupDeployment -ResourceGroupName $resourcegroup `
    #  -TemplateFile all-up-standalone.bicep `
    #  -TemplateParameterFile C:\Temp\odl.parameters.json `
    #  -workspace_name $workspace  `
    #  -dicom_service_name $dicomname            
}

#$location = "East US";
$students | ForEach-Object -ThrottleLimit 30 -Parallel { 
    New-AzResourceGroup -Name $_.resourcegroup -Location "East US";
    New-AzResourceGroupDeployment -ResourceGroupName $_.resourcegroup `
     -TemplateFile all-up-standalone.bicep `
     -TemplateParameterFile $_.parameterfn `
     -workspace_name $_.workspace  `
     -dicom_service_name $_.dicomname;  
    Write-Output "Done"      
}


$wsprefix = "rsnastudent";
$rgprefix = "rnsastudentrg";
$dicomname = "mydicom";
$location = "East US";
20..25 |  ForEach-Object -ThrottleLimit 30 -Parallel { 
            $workspace=$wsprefix+$_; 
            $resourcegroup=$rgprefix+$_; 
            Write-Output $workspace; 
            Write-Output $resourcegroup; 
            Write-Output $dicomname; 
            Write-Output $location

            #New-AzResourceGroup -Name $resourcegroup -Location $location;
            #New-AzResourceGroupDeployment -ResourceGroupName $resourcegroup `
            #  -TemplateFile all-up-standalone.bicep `
            #  -TemplateParameterFile C:\Temp\odl.parameters.json `
            #  -workspace_name $workspace  `
            #  -dicom_service_name $dicomname            
        }




#  Looks like I need to copy the parameters file multiple times, otherwise it can't be read in parallel...
1..99 |  ForEach-Object { 
    $prefix="odl"+$_; 
    $fn=$prefix+".parameters.json";
    Write-Output $fn; 
    Copy-Item "C:\Temp\odl.parameters.json" -Destination "C:\Temp\$fn" -Force
}