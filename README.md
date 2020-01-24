# Deploying a Nodejs App

The project scope is to automate the complete deployment of a Nodejs application with supporting infrastructure (CosmosDB) using Azure Kubernetes Service (AKS).

## Background

The 10x project required the use of Microsoft Azure, automated through pipelines in Visual Studio Team Services (VSTS). The project was broken down into more detail in the project charter, which can be found [here](https://paper.dropbox.com/doc/Azure-Project-Charter-SIppxECKOkMVY1PRzn3zH).

The link to the Trello board for this task can be found [here](https://trello.com/b/x788vkCk/10x-banking-sprint).


## Prerequisites

- Azure portal subscription
- Visual studio team services account

The following bitbucket repository has all the code required to deploy the application through VSTS.

```
git clone https://bitbucket.org/automationlogic/kubernetesapp.git
```

A Docker registry must also be available for pushed images to be created. Create an Azure Container Registry resource:

```
az group create --name <ResourceGroupName> --location <location>

az acr create --name <ContainerRegistryName> \
              --resource-group <ResourceGroupName> \
              --sku Standard \
              --admin-enabled true
```

You must have created a new VSTS project in your service account. A personal access token must be created in VSTS. __Make a note of the PAT created__; you cannot retrieve it once you leave the page.   

__Note:__ Make a note of the container registry name and resource group it was deployed to.


## Document Structure
```
.
├── AKSauth
├── Dockerfile
├── README.md
├── app
│   ├── app.js
│   ├── bin
│   │   └── www
│   ├── config.js
│   ├── models
│   │   ├── docdbUtils.js
│   │   └── taskDao.js
│   ├── package-lock.json
│   ├── package.json
│   ├── public
│   │   └── stylesheets
│   │       └── style.css
│   ├── routes
│   │   ├── index.js
│   │   ├── tasklist.js
│   │   └── users.js
│   └── views
│       ├── error.jade
│       ├── index.jade
│       └── layout.jade
├── definitions
│   ├── build.json
│   ├── release.json
│   └── releasedestroy.json
├── export.sh
├── importDef.sh
├── kub.yaml
└── templates
    ├── infraParameters.json
    └── infraTemplate.json
```
`AKSauth`: Creates service principal to authenticate the Kubernetes cluster with the docker registry

`Dockerfile`: Dockerfile for AKS services

`README.md`: README + Runbook for project

`app` directory: Config files for the nodejs application. Currently a simple 'ToDo' list application for the demo. _Note: config.js file in this directory is the file which configures the connection to the database_

`templates` directory: Contains the ARM template file and parameter file for deployment of the cosmosDB and the Kubernetes cluster

`definitions` directory: Contains the build and release definitions for exporting into VSTS

`export.sh`: Script which exports correct variables for pipeline prerequisites

`importdef.sh`: Automation script for the demo

`kub.yaml`: YAML file which contains the configuration of the kubernetes cluster


## Deployment

1. Install the VSTS-import client:
```
npm i -g vsts-rest
```
2. Login to the Azure cross platform through `az login` and follow the prompt

3. Create a new VSTS project

4. Export required variables:
```
. ./export.sh
```
OR, export them manually
```
export PROJECT_NAME=${PROJECT_NAME}
export VSTS_AZURE_SERVICE=${VSTS_AZURE_SERVICE}
export VSTS_AZURE_DOCKER_REGISTRY=${VSTS_AZURE_DOCKER_REGISTRY}
export VSTS_ACCOUNT=${VSTS_ACCOUNT}
export VSTS_PAT=${VSTS_PAT}
export VSTS_USER=${VSTS_USER}
export ACR_RESOURCE_GROUP=${ACR_RESOURCE_GROUP}
export PRODUCT_NAME=${PRODUCT_NAME}
export SUBid=${SUBid}
export tenantId=${tenantId}
export user64=${user64}
```
5. Finally, to create and run the pipelines:
```
./importdef.sh
```

## Manual Deployment for Developers

_If using a VSTS agent for deployment, the Hosted Linux agent must be used._

### Code

In the VSTS menu, create a new project and navigate to the `Code` section (in the left sidebar of the updated VSTS interface).

The method for CI/CD in this project requires the code to be inside VSTS. The files from the bitbucket repository can be pushed to VSTS manually:

After cloning the bitbucket repository to a local machine, the origin of the bitbucket repository must be changed so that the code can be pushed into VSTS. From the root directory of the bitbucket repository:

```
git remote add vsts
```

The repository can then be pushed to VSTS (these commands can be found in the _Code_ section in an empty VSTS project):

```
git remote add vsts https://<Name_of_VSTS_Account>.visualstudio.com/<Name_of_VSTS_Project/_git/<Name_of_Repository>
git push -u vsts --all
```

### Build
Navigate to the Build section (_Build and Release_ in left sidebar > _Build_) and click _+Import_ in the top right. From here, import the `build.json` from your local machine. This will create the Build pipeline definition.

The steps are broken down as follows:

`Publish Artefact: templates` - This step creates an artefact containing the ARN templates which will be used in the release pipeline for deployment

`Build an image` - This creates the docker image from the _Dockerfile_ in the repository

`Push an image` - This pushes the image to the docker registry in azure

`Transform kub.yaml` - This step adds the correct config to the file which allows it to provision the kubernetes cluster

`Publish Artefact: deploy` - This step creates an artefact which contains the new, provisioned _kub.yaml_ file (the manifest)

### Release
Navigate to the Build section (_Build and Release_ in left sidebar > _Releases_). Create a new definition with an empty process (current VSTS version does not allow you to view all releases without creating one) and then click _View all definitions_.

Click the "_+_" icon above the release defitions and select _import release definition_. From here, import the `release.json` from your local machine.

It is work noting that the release pipeline __cannot__ use code from the VSTS repository, only artefacts created in the build step. The steps are broken down as follows:

`Azure Deployment` - This step uses the templates artefact created in the build to launch the ARM templates. These deploy a CosmosDB and a Kubernetes cluster in Azure

`Azure CLI` - Pulls the primary key from the CosmosDB resource (required for authentication for application to connect)

`Input Database Endpoint` - Replaces the endpoint in the _kub.yaml_ file to match the new CosmosDB

`Azure CLI` - Provisions the Kubernetes nodes with the new _kub.yaml_ file

## Common Problems
- Problem: `VSTS could not find any file matching template file pattern`

Solution: This is usually because in the release definition, the template file location is not correct. Check that the setting has been specified as the Linked artefact instead of URL of the file.

- Problem: Pipeline steps are broken and I need to debug

Solution: Add debug steps to your pipeline for variables and environment variables. Example solution: File directory could not be found  for a release so an `ls` step is added to show if variables lead to the correct directory.

- Problem:
```
Error: The request's result was not as expected: {
  "response": {
    "statusCode": 401,
    "headers": {
      "cache-control": "no-cache, no-store, must-revalidate",
      "pragma": "no-cache",
      "expires": "-1",
```

Solution: Your Azure subscription might be invalid or not have the correct permissions. Check your azure endpoint configuration.


## Termination
- Go to the `Destroy` environment by editing the Release (three dots next to release).
- Click on `Tasks` in the environment.
- Enable the task.
- Save the environment.
- Deploy the `Destroy` environment to destroy all resources including the resource group.
