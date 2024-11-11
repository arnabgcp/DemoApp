

provider "google" {
  project = var.project

}

data "google_service_account" "compute_account" {
  account_id = "406096782694-compute@developer.gserviceaccount.com"
}

resource "google_container_cluster" "primary" {
  name     = var.name
  location = var.loc

  remove_default_node_pool = true
  initial_node_count       = 1

 fleet {
   project = var.project
 }

  private_cluster_config {


    enable_private_nodes = true


     master_ipv4_cidr_block = "10.0.3.0/28"
  }
master_authorized_networks_config {
  
 cidr_blocks {
    cidr_block = "34.124.210.227/32"
    display_name = "my-shell"
  }
 
}
 

      network = var.network
      subnetwork = var.subnetwork
      deletion_protection = false
}

resource "google_container_node_pool" "np" {
  name       = "my-node-pool"

  node_count = var.nodecount
  cluster    = google_container_cluster.primary.id
  node_config {
    machine_type = "e2-medium"
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = data.google_service_account.compute_account.email
    disk_size_gb = 25
  }
  timeouts {
    create = "30m"
    update = "20m"
  }

 
}