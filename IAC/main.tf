
module "network" {

  source = "./module/networks"
  region_pri = "us-east1"
  region_sec = "us-central1"
  project    = "ardent-case-441007-d8"


}


module "gke" {

  source      = "./module/gke"
  loc         = "us-east1-b"
  name        = "cluster-1"
  network     = module.network.network
  subnetwork  = module.network.useast
  project     = "ardent-case-441007-d8"
  nodecount   = 2
  master_ipvr = "10.0.5.0/28"
  shell = "34.124.173.126/32"

}


module "gke2" {

  source      = "./module/gke"
  loc         = "us-central1-a"
  name        = "cluster-2"
  network     = module.network.network
  subnetwork  = module.network.uscen
  project     = "ardent-case-441007-d8"
  nodecount   = 1
  master_ipvr = "10.0.4.0/28"
  shell = "34.124.173.126/32"
}
