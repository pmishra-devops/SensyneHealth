#!/bin/bash

# Misc Variables
echo "Set misc variables:"
echo -n "Azure subscription email login (e.g. danish@automationlogic.onmicrosoft.com): "
read VSTS_USER
if [[ -z ${VSTS_USER} ]]
then
  echo "Please enter the VSTS account name"
  exit 1
fi

echo ""
echo ""

echo -n "Set name for created resources (this will be the prefix for azure resources that are deployed): "
read PRODUCT_NAME
if [[ -z ${PRODUCT_NAME} ]]
then
  echo "Please enter a name for created resources"
  exit 1
fi

echo ""
echo ""

# VSTS Variables
echo "Set VSTS Variables:"
echo -n "VSTS ARM service endpoint name (custom created inside VSTS): "
read VSTS_AZURE_SERVICE
if [[ -z ${VSTS_AZURE_SERVICE} ]]
then
  echo "Please enter the VSTS ARM service endpoint"
  exit 1
fi

echo ""
echo ""

echo -n "VSTS service account name prefix (e.g. 'danish' if name is 'danish.visualstudio.com'): "
read VSTS_ACCOUNT
if [[ -z ${VSTS_ACCOUNT} ]]
then
  echo "Please enter the VSTS service account name prefix"
  exit 1
fi

echo ""
echo ""

echo -n "VSTS personal access token: "
read VSTS_PAT
if [[ -z ${VSTS_PAT} ]]
then
  echo "Please enter VSTS PAT"
  exit 1
fi

echo ""
echo ""

echo -n "Name of VSTS project: "
read PROJECT_NAME
if [[ -z ${PROJECT_NAME} ]]
then
  echo "Please enter a Name for the project"
  exit 1
fi

echo ""
echo ""

# Docker Registry Details
echo "Set docker registry variables:"
echo -n "Azure docker registry name: "
read VSTS_AZURE_DOCKER_REGISTRY
if [[ -z ${VSTS_AZURE_DOCKER_REGISTRY} ]]
then
  echo "Please enter the Azure docker registry name"
  exit 1
fi

echo ""
echo ""

echo -n "Resource Group Docker registry is linked to: "
read ACR_RESOURCE_GROUP
if [[ -z ${ACR_RESOURCE_GROUP} ]]
then
  echo "Please enter the resource group associated with the docker registry"
  exit 1
fi

SUBid=$(az account show --query 'id' -o tsv)
echo "subscription ID: $SUBid"
export SUBid=${SUBid}
tenantId=$(az account show --query 'tenantId' -o tsv)
echo "tenant ID: $tenantId"
export tenantId=${tenantId}
user64=$(echo -n "${VSTS_ACCOUNT}@automationlogic.onmicrosoft.com:${VSTS_PAT}" | base64)
echo "user64: $user64"
export user64=${user64}


export PROJECT_NAME=${PROJECT_NAME}
export VSTS_AZURE_SERVICE=${VSTS_AZURE_SERVICE}
export VSTS_AZURE_DOCKER_REGISTRY=${VSTS_AZURE_DOCKER_REGISTRY}
export VSTS_ACCOUNT=${VSTS_ACCOUNT}
export VSTS_PAT=${VSTS_PAT}
export VSTS_USER=${VSTS_USER}
export ACR_RESOURCE_GROUP=${ACR_RESOURCE_GROUP}
export PRODUCT_NAME=${PRODUCT_NAME}
