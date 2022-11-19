# Download and expand dcmtk
mkdir 'C:\dcmtk\'
$source = 'https://dicom.offis.de/download/dcmtk/dcmtk367/bin/dcmtk-3.6.7-win64-dynamic.zip'
$destination = 'C:\dcmtk\cdmtk.zip'
Invoke-RestMethod -Uri $source -OutFile $destination

Expand-Archive -Path 'C:\dcmtk\cdmtk.zip' -DestinationPath 'C:\dcmtk\'

# Download convenience files for students
mkdir 'C:\downloads'
$source = 'https://raw.githubusercontent.com/StevenBorg/ahds_dicom_service_demos/main/uploads/Orthanc.url'
$destination = 'C:\downloads\Orthanc.url'
Invoke-RestMethod -Uri $source -OutFile $destination

$source = 'https://raw.githubusercontent.com/StevenBorg/ahds_dicom_service_demos/main/uploads/Qvera%20Interface%20Engine.url'
$destination = 'C:\downloads\Qvera%20Interface%20Engine.url'
Invoke-RestMethod -Uri $source -OutFile $destination

$source = 'https://github.com/StevenBorg/ahds_dicom_service_demos/blob/main/uploads/qie_MicrosoftDICOM.qie'
$destination = 'C:\downloads\qie_MicrosoftDICOM.qie'
Invoke-RestMethod -Uri $source -OutFile $destination

$source = 'https://www.dicomlibrary.com?study=1.2.826.0.1.3680043.8.1055.1.20111102150758591.92402465.76095170'
$destination = 'C:\downloads\sample.dcm'
Invoke-RestMethod -Uri $source -OutFile $destination

New-LocalUser -Name "student" -Description "Description of this account." -NoPassword

$source = 'https://raw.githubusercontent.com/StevenBorg/ahds_dicom_service_demos/main/uploads/Orthanc.url'
$destination = 'C:\Users\student\Desktop\Orthanc.url'
Invoke-RestMethod -Uri $source -OutFile $destination