resource "google_compute_instance" "boundary_controller" {
  count        = var.boundary_controller_count
  name         = "boundary-controller-${count.index}"
  machine_type = var.machine_type
  zone         = "${var.region}-${var.zone[0]}"

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.operating_system
    }
  }

  network_interface {
    network = var.network

    access_config {
    }
  }

  service_account {
    scopes = var.service_account_scopes
  }
}

resource "google_compute_instance" "boundary_worker" {
  count        = var.boundary_worker_count
  name         = "boundary-worker-${count.index}"
  machine_type = var.machine_type
  zone         = "${var.region}-${var.zone[0]}"

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.operating_system
    }
  }

  network_interface {
    network = var.network

    access_config {
    }
  }

  service_account {
    scopes = var.service_account_scopes
  }
}
