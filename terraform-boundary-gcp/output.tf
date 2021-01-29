resource "local_file" "ansible_inventory" {
  content = templatefile("templates/inventory.tpl", {
    boundary_workers     = google_compute_instance.boundary_worker.*.network_interface.0.access_config.0.nat_ip
    boundary_controllers = google_compute_instance.boundary_controller.*.network_interface.0.access_config.0.nat_ip
    boundary_database    = google_sql_database_instance.boundary.ip_address.0.ip_address
  })

  filename = "ansible/inventory"
}

output "boundary_psql_password" {
  value = random_id.boundary_psql_password.hex
}