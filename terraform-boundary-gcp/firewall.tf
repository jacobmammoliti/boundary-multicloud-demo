resource "google_compute_firewall" "boundary" {
  name    = "boundary"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9200", "9202"]
  }

  target_tags   = ["boundary"]
  source_ranges = ["0.0.0.0/0"]
}