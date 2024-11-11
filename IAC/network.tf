# VPC network
resource "google_compute_network" "network" {
  name                    = "prim-network"
  auto_create_subnetworks = false
}

# backend subnet
resource "google_compute_subnetwork" "useast_subnet" {
  name          = "useast-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region_pri
  network       = google_compute_network.network.id
}


resource "google_compute_subnetwork" "uswest_subnet" {
  name          = "useast-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region_sec
  network       = google_compute_network.network.id
}