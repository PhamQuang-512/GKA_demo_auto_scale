output "nat_address_type" {
  value = google_compute_address.nat_address.address_type
}

output "nat_ip_address" {
  value = google_compute_address.nat_address.address
}

output "gke_master_ip" {
  value = google_container_cluster.auto_scale_demo.endpoint
}
