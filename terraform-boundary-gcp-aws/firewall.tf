# Get info on provided GCP network
data "google_compute_network" "boundary_network" {
  name = var.gcp_network
}

# Get ID of provided AWS VPC
data "aws_vpc" "boundary_network" {
  id = var.aws_vpc_id
}

# Create a firewall rule for Boundary worker(s) and controller(s)
resource "google_compute_firewall" "boundary" {
  name    = "boundary"
  network = data.google_compute_network.boundary_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["9200", "9201", "9202"]
  }

  target_tags   = var.tags
  source_ranges = ["0.0.0.0/0"]
}

# Create a designated security group for Boundary worker(s)
resource "aws_security_group" "boundary" {
  name   = "boundary"
  vpc_id = data.aws_vpc.boundary_network.id
}

# Allow SSH traffic to Boundary worker(s)
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary.id
}

# Allow all traffic on ports 9200-9202 for Boundary
resource "aws_security_group_rule" "allow_boundary" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9202
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary.id
}

# Allow all traffic outbound 
resource "aws_security_group_rule" "allow_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary.id
}