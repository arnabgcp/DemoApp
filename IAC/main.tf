module "network"{

source = "./module/networks"

region_pri="us-east1"
region_sec="us-west1"
project="ardent-case-441007-d8"


}


module "gke"{

source = "./module/gke"
loc = "us-east1-b"
name= "cluster-1"
network = module.network.network 
subnetwork = module.network.useast
project="ardent-case-441007-d8"
nodecount = 2

master_ipvr = "10.0.5.0/28"

}


module "gke2"{

source = "./module/gke"
loc = "us-west1-a"
name= "cluster-2"
network = module.network.network 
subnetwork = module.network.uswest
project="ardent-case-441007-d8"
nodecount = 1

master_ipvr = "10.0.4.0/28"
}