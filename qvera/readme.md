# Qvera QIE
Qvera QIE is a professional, scriptable healthcare router that can easily handle DICOM interactions between systems, including the AHDS DICOM service. For more information see: https://www.qvera.com/hl7-interface-engine/

Full guidance to configure QIE to interact with the DICOM service is available here: _insert link to guidance_

Using Qvera QIE requires a license. A 90-day trial license is easily available at https://www.qvera.com/hl7-interface-engine/#get-started-section. Scroll down to click the **Start a Free 90-day Trial** button, enter some information, and a key will be emailed immediately to your account.

QIE can be installed in many different configurations, including horizontally scaled architectures. For our demo purposes, however, we'll base the demo the Docker container available here: https://hub.docker.com/r/qvera/qie

Additionally, we'll run QIE in Azure Container Instances. This is an easy deployment, but is limited in size to 4 Virtual CPUs and 16 GB of RAM. Using the max size is recommended since DICOM files tend to be large.

To simplify the use of QIE in demos, the associated Dockerfile modifies the base Docker file to include appropriate configurations.

Qvera QUI has two different versions provided. 
- 5.0.50: This is an all-in-one version that includes a database and is ready to run
- 5.0.51: This is a later version and requires a separate DB instance to run. The Docker Compose file makes it easy, but deployment to Azure Container Instances isn't working yet.

### 5.0.50
To deploy this version, simply run the Bicep deployment for 