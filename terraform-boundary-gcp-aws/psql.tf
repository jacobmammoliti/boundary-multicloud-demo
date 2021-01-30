# Generate a random suffix for Boundary CloudSQL instance
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Create a CloudSQL PostgreSQL instance for Boundary
resource "google_sql_database_instance" "boundary" {
  name             = "boundary-${random_id.db_name_suffix.hex}"
  database_version = var.postgresql_version
  region           = var.gcp_region

  deletion_protection = false

  settings {
    tier = var.postgresql_tier

    ip_configuration {
      ipv4_enabled = true

      authorized_networks {
        value = "0.0.0.0/0"
      }
    }
  }
}

# Create an SQL database for Boundary
resource "google_sql_database" "boundary_database" {
  name     = "boundary"
  instance = google_sql_database_instance.boundary.name
}

# Generate a random string for the Boundary SQL user's password
resource "random_id" "boundary_psql_password" {
  byte_length = 15
}

# Create an SQL user for Boundary to use
resource "google_sql_user" "boundary_user" {
  name     = "boundary"
  instance = google_sql_database_instance.boundary.name
  password = random_id.boundary_psql_password.hex
}