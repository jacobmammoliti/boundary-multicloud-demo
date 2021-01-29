resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "ssh_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "google_compute_instance" "boundary_controller" {
  count        = var.boundary_controller_count
  name         = "boundary-controller-${count.index}"
  machine_type = var.machine_type
  zone         = "${var.gcp_region}-${var.zone[0]}"

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

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.ssh_key.public_key_openssh}"
  }

  service_account {
    scopes = var.service_account_scopes
  }
}

resource "google_compute_instance" "boundary_worker" {
  count        = var.boundary_worker_count
  name         = "boundary-worker-${count.index}"
  machine_type = var.machine_type
  zone         = "${var.gcp_region}-${var.zone[0]}"

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

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.ssh_key.public_key_openssh}"
  }

  service_account {
    scopes = var.service_account_scopes
  }
}

resource "aws_instance" "boundary_worker" {
  count         = var.boundary_worker_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name      = aws_key_pair.generated_key.key_name

  tags = {
    Name = "boundary-worker-${count.index}"
  }
}