# Generate an SSH key to distribute across all controller(s)
# and worker(s)
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

# Create an AWS key pair for the AWS worker(s)
# GCP allows us to inject it directly in the compute resource
resource "aws_key_pair" "generated_key" {
  key_name   = "ssh_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Get the latest Ubuntu 20.04 image for the AWS worker(s)
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

# Provision Boundary controller(s) in GCP
resource "google_compute_instance" "boundary_controller" {
  count        = var.boundary_controller_count
  name         = "boundary-controller-${count.index}"
  machine_type = var.gcp_machine_type
  zone         = "${var.gcp_region}-${var.zone[0]}"

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.operating_system
    }
  }

  network_interface {
    network = data.google_compute_network.boundary_network.self_link

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

# Provision Boundary worker(s) node in GCP
resource "google_compute_instance" "boundary_worker" {
  count        = var.boundary_worker_count
  name         = "boundary-worker-${count.index}"
  machine_type = var.gcp_machine_type
  zone         = "${var.gcp_region}-${var.zone[0]}"

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.operating_system
    }
  }

  network_interface {
    network = data.google_compute_network.boundary_network.self_link

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

# Provision Boundary worker(s) node in AWS
resource "aws_instance" "boundary_worker" {
  count                  = var.boundary_worker_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.aws_machine_type
  vpc_security_group_ids = [aws_security_group.boundary.id]

  associate_public_ip_address = true

  key_name = aws_key_pair.generated_key.key_name

  tags = {
    Name = "boundary-worker-${count.index}"
  }
}