resource "google_container_cluster" "auto_scale_demo" {
  name                     = "auto-scale-demo"
  location                 = var.zone
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.main.id
  subnetwork               = google_compute_subnetwork.private.id
  monitoring_service       = "none"
  logging_service          = "none"
  networking_mode          = "VPC_NATIVE"

  #   node_locations = ["asia-east1-a"]

  addons_config {
    http_load_balancing {
      disabled = true # use nginx ingress controller -> no need for this
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  # cluster_autoscaling {
  #   enabled = false
  #   resource_limits {
  #     resource_type = "cpu"
  #     minimum       = 1
  #     maximum       = 10
  #   }
  #   resource_limits {
  #     resource_type = "memory"
  #     minimum       = 1
  #     maximum       = 10
  #   }
  # }
}


resource "google_container_node_pool" "np1" {
  name       = "np1"
  cluster    = google_container_cluster.auto_scale_demo.name
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = false
    machine_type = "e2-small"
    disk_size_gb = 10

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  autoscaling {
    total_min_node_count = 1
    total_max_node_count = 10
    location_policy      = "BALANCED"
  }
}
