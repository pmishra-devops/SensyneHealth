
variable "username" {
  default = "admin"
}
variable "password" {}

variable "cluster_name" {}

# https://www.terraform.io/docs/providers/google/r/container_cluster.html#tags
variable "tags" {
  type        = "list"
  default     = []
  description = "The list of instance tags applied to all nodes. Tags are used to identify valid sources or targets for network firewalls"
}

# https://www.terraform.io/docs/providers/google/r/container_cluster.html#labels
variable "labels" {
  description = "The Kubernetes labels (key/value pairs) to be applied to each node"
  type        = "map"
  default     = {}
}

# https://www.terraform.io/docs/providers/google/r/container_cluster.html#metadata
variable "metadata" {
  description = "The metadata key/value pairs assigned to instances in the cluster"
  type        = "map"
  default     = {}
}
variable "node_pools" {
  type              = "list"
  default           = []
  description       = "Settings for node pool(s), provide as list of mappings (dictionariesw)"
}
variable "global" {
  type        = "map"
  default     = {}
  description = "Global parameters"
}
variable "service_account_file_basepath" {
  type = "string"
  description = "The basepath for the location that you store the service account json file in."
}
################################################################################
################################################################################
# All below are set as environment variables
variable "project_id" {
	type = "string"
	description = "the unique project ID to create resources in"
}
variable "region" {
	type = "string"
	description = "The region to create resources in"
}
variable "location" {
	type = "string"
	description = "the location (e.g. <region> a, b or c) to create resources in"
}
variable "env" {
	type = "string"
	description = "the logical environment to create resources in (defaults to dev for safety)"
	default = "dev"
}
variable "bucket_name" {
	type = "string"
	description = "the DNS resolvable name of the bucket in which we will be storing state"
	default = "dev"
}
