# VPC network

provider "google" {
  project = var.project

}

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


resource "google_compute_subnetwork" "uscen_subnet" {
  name          = "uscen-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region_sec
  network       = google_compute_network.network.id
}

resource "google_compute_router" "router_east" {
  name    = "us-east-router"
  region  = google_compute_subnetwork.useast_subnet.region
  network = google_compute_network.network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_east" {
  name                               = "us-east-router-nat"
  router                             = google_compute_router.router_east.name
  region                             = google_compute_router.router_east.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

}


resource "google_compute_router" "router_cen" {
  name    = "us-cen-router"
  region  = google_compute_subnetwork.uscen_subnet.region
  network = google_compute_network.network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_cen" {
  name                               = "us-cen-router-nat"
  router                             = google_compute_router.router_cen.name
  region                             = google_compute_router.router_cen.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

}