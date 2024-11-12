output "useast" {
  value = google_compute_subnetwork.useast_subnet.id
}


output "uscen" {
  value = google_compute_subnetwork.uscen_subnet.id
}

output "network" {
  value = google_compute_network.network.id
}