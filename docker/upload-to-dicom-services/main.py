#!/usr/bin/env python
# coding: utf-8

# In[ ]:


# Imports
import azure.storage.blob as asb
from azure.identity import DefaultAzureCredential
import os
import requests
from io import BytesIO
import json


# In[ ]:


#These need to env variables in the docker container
#AZURE_CLIENT_ID: id of an Azure Active Directory application
#AZURE_TENANT_ID: d of the application's Azure Active Directory tenant
#AZURE_CLIENT_SECRET: one of the application's client secrets
#STORAGE_CONNSTR: connection string to the storage accound with the DICOM files
#BLOB_CONTAINER: Container containing the DICOM files
#DICOM_URL: URL to the DICOM Service - be sure the Client ID has Dicom Data Owner permissions on the DICOM service

# Use environmental variables
storageConnString = os.getenv('STORAGE_CONNSTR')
dicomContainer = os.getenv('BLOB_CONTAINER')
dicomUrl = os.getenv('DICOM_URL')

if (storageConnString is None):
    raise Exception('Missing storage connection string')

if (dicomContainer is None):
    raise Exception('Missing dicom container')
    
if (dicomUrl is None):
    raise Exception('Missing DICOM URL')

print(storageConnString)
print(dicomContainer)
print(dicomUrl)


# In[ ]:


blob_container_sync = asb.ContainerClient.from_connection_string(conn_str=storageConnString,container_name=dicomContainer)

try:
    p = blob_container_sync.get_container_properties()
except:
    raise Exception('Cannot connect to storage container')


# In[ ]:


# Needed functions for upload
from urllib3.filepost import encode_multipart_formdata, choose_boundary

def encode_multipart_related(fields, boundary=None):
    if boundary is None:
        boundary = choose_boundary()

    body, _ = encode_multipart_formdata(fields, boundary)
    content_type = str('multipart/related; boundary=%s' % boundary)

    return body, content_type

def upload_single_dcm_file(server_url,filepath):
    with open(filepath,'rb') as reader:
        rawfile = reader.read()
    files = {'file': ('dicomfile', rawfile, 'application/dicom')}

    #encode as multipart_related
    body, content_type = encode_multipart_related(fields = files)
    
    headers = {'Accept':'application/dicom+json', "Content-Type":content_type, }

    response = requests.post(server_url, body, headers=headers) #, verify=False)
    
    return response

def upload_single_dcm_bytes(server_url,file_bytes):
    #with open(filepath,'rb') as reader:
    #    rawfile = reader.read()
    files = {'file': ('dicomfile', file_bytes, 'application/dicom')}

    #encode as multipart_related
    body, content_type = encode_multipart_related(fields = files)
    
    headers = {'Accept':'application/dicom+json', "Content-Type":content_type, "Authorization":bearer_token}

    response = requests.post(server_url, body, headers=headers) #, verify=False)
    
    #return the response object to allow for further processing
    
    #example usage
    #r = upload_single_dcm_file(url,'C:\\githealth\\dicom-samples\\visus.com\\case4\\case4a_002.dcm')
    #print(r.status_code)
    #print(r.request.headers)
    
    return response


# In[ ]:


credential = DefaultAzureCredential()
scope = "https://dicom.healthcareapis.azure.com/.default"
token = credential.get_token(scope)
#print(token.token)
bearer_token = f'Bearer {token.token}'


# In[ ]:


url = dicomUrl+'/v1'
stow_url = url + "/studies"
print(stow_url)


# In[ ]:


generator = blob_container_sync.list_blobs()  
print('starting upload')
#for blob in generator:
#    print("Blob name: " + blob.name)
for file in generator:
    # Download from blob store
    fbytes = blob_container_sync.download_blob(blob=file).content_as_bytes()
    print(len(fbytes))
    #
    # Upload a single file at a time (and time it)
    r = upload_single_dcm_bytes(stow_url,fbytes)     # call API and get response 
    print("*")


# In[ ]:





# In[ ]:




