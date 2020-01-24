#!/bin/bash

# Created before xv so secrets don't appear in logs
password=ALsecret1234
servicePrincipalClientId="$(az ad sp create-for-rbac --password $password --skip-assignment --output tsv --query "appId")"

set -xv

cd "$(dirname "$0")"

#Generic setup
builddef='./definitions/build.json'
releasedef='./definitions/releasedestroy.json'
rand=$(date +%s)

#var checks
: "${PROJECT_NAME?Need to set PROJECT_NAME}"
: "${VSTS_AZURE_SERVICE?Need to set VSTS_AZURE_SERVICE}"
: "${VSTS_AZURE_DOCKER_REGISTRY?Need to set VSTS_AZURE_DOCKER_REGISTRY}"
: "${ACR_RESOURCE_GROUP?Need to set ACR_RESOURCE_GROUP}"

# Needs fix - current resolve is sleep command
until az ad sp show --id $servicePrincipalClientId
do
	sleep 1
done
sleep 10
az role assignment create --assignee ${servicePrincipalClientId} --resource-group $ACR_RESOURCE_GROUP --role Reader

#Product specific vars
PRODUCT_NAME=${PRODUCT_NAME}
PRODUCT_NAME_LOWERCASE=$(echo "$PRODUCT_NAME" | tr '[:upper:]' '[:lower:]')
releasedefname=${PRODUCT_NAME}_$rand
PROJECT_NAME_LOWER=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
AZURE_SERVICE_ID=$(vsts-getservices $PROJECT_NAME | jq -r  ".[] | select(.name==\"$VSTS_AZURE_SERVICE\") | .id")
VSTS_AZURE_DOCKER_REGISTRY_LOWERCASE=$(echo "$VSTS_AZURE_DOCKER_REGISTRY" | tr '[:upper:]' '[:lower:]')
VSTS_DOCKER_REGISTRY_HOST=$VSTS_AZURE_DOCKER_REGISTRY_LOWERCASE.azurecr.io
REGISTRY_INPUT_STRING="{\"loginServer\":\"$VSTS_DOCKER_REGISTRY_HOST\"}"
REPLACEMENT_VARIABLES="sed -i 's/\$BUILD_ID/\$(Build.BuildId)/; s/\$ACR_DNS/$VSTS_DOCKER_REGISTRY_HOST/; s/projectname/$PROJECT_NAME_LOWER/' kub.yaml"

#Endpoint automation
curl -X POST \
   -H "Authorization:Basic ${user64}" \
   -H "Content-Type:application/json" \
   -d \
'{
  "data": {
    "SubscriptionId": "'${SUBid}'",
    "SubscriptionName": "Pay-As-You-Go",
    "creationMode": "Automatic",
  },
  "name": "'${VSTS_AZURE_SERVICE}'",
  "type": "azurerm",
  "authorization": {
    "parameters": {
        "tenantid": "'${tenantId}'",
        "serviceprincipalkey": null
    },
    "scheme": "ServicePrincipal"
  },
  "isReady": false
}' \
 "https://${VSTS_ACCOUNT}.visualstudio.com/${PROJECT_NAME}/_apis/serviceendpoint/endpoints?api-version=4.1-preview.1"

sleep 10

#Go
vsts-import $PROJECT_NAME \
-g https://bitbucket.org/automationlogic/kubernetesapp/src/master/ \
	-b $builddef \
	-r $releasedef \
	--releaseagent "Hosted Linux Preview" \
	--buildagent "Hosted Linux Preview" \
  --releaseservice "connectedServiceNameARM=$VSTS_AZURE_SERVICE" \
	--releaseservice "ConnectedServiceName=$VSTS_AZURE_SERVICE" \
	--releaseservice "azureSubscriptionEndpoint=$VSTS_AZURE_SERVICE" \
	--buildservice "azureSubscriptionEndpoint=$VSTS_AZURE_SERVICE" \
	-v clusterName=${PRODUCT_NAME_LOWERCASE}cluster$rand \
  -v dbname=${PRODUCT_NAME_LOWERCASE}db$rand \
  -v servicePrincipalClientId=$servicePrincipalClientId \
  -v servicePrincipalClientSecret=$password \
  -v registryName=$VSTS_AZURE_DOCKER_REGISTRY \
  -v resourcegroup=${PRODUCT_NAME}$rand \
	--buildjsonpath "$.process.phases[*].steps[?(@.displayName=='Build an image')].inputs.azureContainerRegistry=$REGISTRY_INPUT_STRING" \
	--buildjsonpath "$.process.phases[*].steps[?(@.displayName=='Push an image')].inputs.azureContainerRegistry=$REGISTRY_INPUT_STRING" \
  --buildjsonpath "$.process.phases[*].steps[?(@.displayName=='transform kub.yaml')].inputs.script=$REPLACEMENT_VARIABLES" \
  --releasedefname "$releasedefname"
