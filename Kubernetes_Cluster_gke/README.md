Kubernetes cluster created in GKE with multiple node pools


![A diagram of the example configuration that comes with this repository.](diagram.jpg)

This diagram shows the architecture of what is deployed by this repository, by default the kubernetes cluster exists within europe-west2-b. Each node pool starts with a single node and automatically scales up to 3 nodes in each node pool.
# Dependencies
* Terraform
* openssl (to generate a secure random password)
* gcloud (the google cloud CLI)
* gsutil

# Initialisation

Throughout we'll be using a few environment variables, these will be fed as variables to terraform and the bash set up scripts below. We'll define them here and use them throughout.

In the interests of variable sanitation we will be unsetting these variables at the very last step of this walkthrough.


```
## RUN ME (with filled in variables)

export TF_VAR_project_id="imarealfungi-1551974438618" && \
export TF_VAR_region="europe-west2" && \
export TF_VAR_location="${TF_VAR_region}-b" && \
export TF_VAR_environment="dev" && \
export TF_VAR_bucket_name=${TF_VAR_project_id}-${TF_VAR_environment} && \

# Secure variables
# Automatically generate a secure password for the cluster
export TF_VAR_password="$(openssl rand 14 -base64)"
```


## gcloud CLI installation
We'll very briefly run through the set up of gcloud in case you've never used it before.
```
## RUN ME

# Install CLI
brew install gcloud && \

# Log in
gcloud auth login && \

# Set active project
gcloud config set project ${TF_VAR_project_id}
```

## Service account
# We can automate this step with a little difficulty, but it's totally doable
You must first create a google service account to use with terraform. Please see `https://developers.google.com/android/management/service-account` to see how to do this.

When you have created a service account you will download a .json file which provide credentials for that service account. Store the json file it provides you at the location specified in `service_account_file_basepath` (notice that this variable already has the trailing "/" ).

One must name the file with your unique project ID.

The full path for the example configuration is

```
# <service_account_file_basepath><project_ID>
~/.gcloud/service_account_keys/imarealfungi-1551974438618
```
## Bucket creation for state
We need to create a bucket in which we will store the state of this deployment.

https://cloud.google.com/storage/docs/gsutil/commands/mb

## State
By default the state of the cluster is stored in a bucket, you could initialise it as below or however you'd like but it must use the below variables:

* -p: specify the project with which your bucket will be associated.
* -c: specify the default storage class of your bucket.
* -l: specify the location of your bucket.

You'll be glad to hear that we're using the more modern ``
NB: see `https://cloud.google.com/storage/docs/creating-buckets#storage-create-bucket-gsutil` for more information.

```
## RUN ME

gsutil mb \
	-p ${TF_VAR_project_id} \
	-l ${TF_VAR_region} \
	gs://${TF_VAR_bucket_name}
```


## Unset environment variables
```
# PLEASE BE AWARE that this unsets all environment variables of the form TF_VAR_* except for TF_VAR_password which is only stored in memory.

# Currently unsets all variables, including the password
# Correction: it doesn't work.
unset TF_VAR_*

```
