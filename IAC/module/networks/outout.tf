output "useast" {
  value = google_compute_subnetwork.useast_subnet.id
}


output "uswest" {
  value = google_compute_subnetwork.uswest_subnet.id
}

output "network" {
  value = google_compute_network.network.id
}