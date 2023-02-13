resource "google_compute_network" "gcp-vpc" {
    name = "gcp-vpc"
    project = var.project_id
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public-subnet" {
    name = "public-subnet"
    project = var.project_id
    ip_cidr_range = "10.0.0.0/24"
    region = var.region
    network = google_compute_network.gcp-vpc.self_link
    private_ip_google_access = false

    secondary_ip_range {
    range_name    = "first-range"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "second-range"
    ip_cidr_range = "10.2.0.0/20"
  }
  
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.gcp-vpc.name
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_router" "router" {
    name = "router"
    region = var.region
    project = var.project_id
    network = google_compute_network.gcp-vpc.self_link
}

resource "google_compute_instance" "gcp_instance" {
  name = "gcp-instance"
  project = var.project_id
  machine_type = "f1-micro"
  zone = var.zone
  tags = ["ssh"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.gcp-vpc.name
    subnetwork = google_compute_subnetwork.public-subnet.name
    subnetwork_project = var.project_id
  }

  depends_on = [
    google_compute_network.gcp-vpc,
  ]
}
