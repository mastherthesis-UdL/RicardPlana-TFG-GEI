# TFG Repository
* Title: Design and implementation of a platform to integrate pharmacological data and grant access to perform studies and analítics and provide tools to Exchange and disseminate the results.
* Author: Ricard Plana Llauradó.
* University: Universitat de Lleida (UDL)
* Bachelor's degree: Informatics Engineering

## Resume
The healthcare industry historically has generated large amounts of data, driven by record keeping, compliance and regulatory requirement, and patient care. While most data is stored in hard copy form, the current trend is toward rapid digitalization of these large amounts of data. The main practical problem that confronts us is the used technologies to store it, is non-regulated or non-standard relational databases storing yearly datasets. To overcome the challenges exposed until now, we propose a generic architecture and provide guidelines on how to adapt the architecture to different scenarios, the main contribution of this work are: Propose data pre-processing strategies and design a scalable platform that permits to build data-driven models on the top. To validate this architecture design, pharmacology sector will be used as case study.

## Methodology
The implementation proposed was divided in 3 different layers, with at least a micro-service in it:

![Layers (1)](https://user-images.githubusercontent.com/38788944/125190772-1c447e80-e23f-11eb-9703-0e92ddc88b00.png)

**Data Layer** will contain all the raw data and our database micro-system.
**Logic layers** includes all the processes to import the data in the new environment and the different scripts made to interact directly with the access files and the API micro-system to interact with the data in the data layer.
**Presentation Layer** is focused mainly to contain graphic interface we made to be able to check some data without the need to perform any request and being able to check it in a way friendly view.
## Prequisites
In order to be able to properly run our platform, some features would need to be installed. They are:
* Docker
* MongoDB

## Run
### Preprocessing and import data to MongoDB

**We must take in consideration that file must be named "name_year.csv". To properly work it will need to contain the "_year" to be able to fill the history of fields, and mark the new registers and mark the year of them.**
```sh
cd data_integration
python3 import_mongo.py [ip] [port] <file_path>
```
After the first import agains the mongodb, a second script must be executed in order to boost the next imports and to include to the collection extra info that could be needed in future.
```sh
python3 import_drugs.py [ip] [port] <file_path>
```
If ip and port from our mongodb is not included it will assume that the service is actually running in localhost, while being executing remotly they will need to be included
### Docker container with the micro-services
As soon as we have Docker installed and the data imported to our MongoDB, we will only need to run our Docker-Compose file.
```sh
cd ..
docker-compose -d --build
```
The first time our container will be used, it will took several minutes in order to start operating.
