node_pools = [
	{
		auto_repair       				= true
	  auto_upgrade      				= true
	  min_node_count    				= 1
		node_count								= 1
	  max_node_count    				= 3
	  oauth_scopes      				= "https://www.googleapis.com/auth/compute,https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring"
	  machine_type      				= "custom-2-4096"
	  disk_size_gb   				    = 35
	  preemptible    			  	  = false
	  local_ssd_count 				  = 0
	  service_account 				  = "default"
		image 										= "COS"
		},
	{
		auto_repair   				    = true
	  auto_upgrade   				    = true
	  min_node_count 				    = 1
		node_count 								= 1
	  max_node_count 		    	  = 3
	  oauth_scopes   					  = "https://www.googleapis.com/auth/compute,https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring"
	  machine_type  				    = "custom-1-2048"
	  disk_size_gb  				    = 35
	  preemptible   				    = false
	  local_ssd_count 				  = 0
	  service_account 				  = "default"
		image 										= "COS"
	}
]

cluster_name 									= "marjorie"

username 											= "admin"

labels = {

}
metadata = {
	env  												= "dev"
}
tags = [
	"will",
	"this",
	"work",
	"?"
]
service_account_file_basepath = "~/.gcloud/service_account_keys/"

location = "europe-west2-b"
project_id = "imarealfungi-1551974438618"
region = "europe-west2"
