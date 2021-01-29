resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "boundary" {
  name             = "boundary-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_12"
  region           = var.gcp_region
  
  deletion_protection = false

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      authorized_networks {
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_database" "boundary_database" {
  name     = "boundary"
  instance = google_sql_database_instance.boundary.name
}

resource "random_id" "boundary_psql_password" {
  byte_length = 15
}

resource "google_sql_user" "boundary_user" {
  name     = "boundary"
  instance = google_sql_database_instance.boundary.name
  password = random_id.boundary_psql_password.hex
}