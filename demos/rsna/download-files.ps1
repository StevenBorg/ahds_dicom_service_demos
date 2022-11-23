# # Download and expand dcmtk
# mkdir 'C:\dcmtk\'
# $source = 'https://dicom.offis.de/download/dcmtk/dcmtk367/bin/dcmtk-3.6.7-win64-dynamic.zip'
# $destination = 'C:\dcmtk\dcmtk.zip'
# Invoke-RestMethod -Uri $source -OutFile $destination

# Expand-Archive -Path 'C:\dcmtk\dcmtk.zip' -DestinationPath 'C:\dcmtk\'

https://github.com/malaterre/GDCM/releases/download/v3.0.20/GDCM-3.0.20-Windows-x86_64.zip?raw=true
mkdir 'C:\gdcm\'
$source = 'https://github.com/malaterre/GDCM/releases/download/v3.0.20/GDCM-3.0.20-Windows-x86_64.zip?raw=true'
$destination = 'C:\gdcm\gdcm.zip'
Invoke-RestMethod -Uri $source -OutFile $destination

Expand-Archive -Path 'C:\gdcm\gdcm.zip' -DestinationPath 'C:\gdcm\'

# Download convenience files for students
mkdir 'C:\downloads'
$source = 'https://raw.githubusercontent.com/StevenBorg/ahds_dicom_service_demos/main/uploads/Orthanc.url'
$destination = 'C:\downloads\Orthanc.url'
Invoke-RestMethod -Uri $source -OutFile $destination

$source = 'https://raw.githubusercontent.com/StevenBorg/ahds_dicom_service_demos/main/uploads/Qvera%20Interface%20Engine.url'
$destination = 'C:\downloads\QveraInterfaceEngine.url'
Invoke-RestMethod -Uri $source -OutFile $destination

# $source = 'https://github.com/StevenBorg/ahds_dicom_service_demos/blob/main/uploads/qie_MicrosoftDICOM.qie?raw=true'
# $destination = 'C:\downloads\qie_MicrosoftDICOM.qie'
# Invoke-RestMethod -Uri $source -OutFile $destination

$source = 'https://www.dicomlibrary.com?study=1.2.826.0.1.3680043.8.1055.1.20111102150758591.92402465.76095170'
$destination = 'C:\downloads\sample.dcm'
Invoke-RestMethod -Uri $source -OutFile $destination

$source = 'https://github.com/StevenBorg/ahds_dicom_service_demos/blob/main/uploads/qie_MicrosoftDICOM_20221121.qie?raw=true'
$destination = 'C:\downloads\qie_MicrosoftDICOM_20221120_multithreaded.qie'
Invoke-RestMethod -Uri $source -OutFile $destination


$source = 'https://raw.githubusercontent.com/StevenBorg/ahds_dicom_service_demos/main/uploads/Qvera%20Interface%20Engine.url'
$destination = 'C:\Users\Default\Desktop\QveraInterfaceEngine.url'
Invoke-RestMethod -Uri $source -OutFile $destination