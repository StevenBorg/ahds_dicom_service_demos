mkdir 'C:\downloadedFiles\'
$source = 'https://github.com/StevenBorg/ahds_dicom_service_demos/blob/main/products/qvera/qie_MicrosoftDICOM.qie?raw=true'
$destination = 'C:\downloadedFiles\qie_MicrosoftDICOM.qie'
Invoke-RestMethod -Uri $source -OutFile $destination