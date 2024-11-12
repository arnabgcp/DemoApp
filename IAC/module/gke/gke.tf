

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


    master_ipv4_cidr_block = var.master_ipvr
  }
  master_authorized_networks_config {

    cidr_blocks {
      cidr_block   = var.shell
      display_name = "my-shell"
    }

    cidr_blocks {
      cidr_block   = "35.237.133.64/32"
      display_name = "nat-1"
    }

    cidr_blocks {
      cidr_block   = "34.57.51.77/32"
      display_name = "nat-2"
    }

    cidr_blocks {
      cidr_block   = "35.184.38.79/32"
      display_name = "vault-vm"
    }
    
    
  }


  network             = var.network
  subnetwork          = var.subnetwork
  deletion_protection = false
}

resource "google_container_node_pool" "np" {
  name = "my-node-pool"

  node_count = var.nodecount
  cluster    = google_container_cluster.primary.id
  node_config {
    machine_type = "e2-medium"
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = data.google_service_account.compute_account.email
    disk_size_gb    = 25
  }
  timeouts {
    create = "30m"
    update = "20m"
  }


}