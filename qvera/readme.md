# Qvera QIE
Qvera QIE is a professional, scriptable healthcare router that can easily handle DICOM interactions between systems, including the AHDS DICOM service. For more information see: https://www.qvera.com/hl7-interface-engine/

Full guidance to configure QIE to interact with the DICOM service is available here: _insert link to guidance_

Using Qvera QIE requires a license. A 90-day trial license is easily available at https://www.qvera.com/hl7-interface-engine/#get-started-section. Scroll down to click the **Start a Free 90-day Trial** button, enter some information, and a key will be emailed immediately to your account.

QIE can be installed in many different configurations, including horizontally scaled architectures. For our demo purposes, however, we'll base the demo the Docker container available here: https://hub.docker.com/r/qvera/qie

Additionally, we'll run QIE in Azure Container Instances. This is an easy deployment, but is limited in size to 4 Virtual CPUs and 16 GB of RAM. Using the max size is recommended since some smaller sizes cause errors and prevent QIE from being configured properly.

To simplify the use of QIE in demos, the associated Dockerfile modifies the base Docker file to include appropriate configurations.

