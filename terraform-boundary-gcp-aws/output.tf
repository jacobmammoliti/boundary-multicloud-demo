resource "local_file" "ansible_inventory" {
  content = templatefile("templates/inventory.tpl", {
    boundary_workers     = concat(google_compute_instance.boundary_worker.*.network_interface.0.access_config.0.nat_ip, aws_instance.boundary_worker.*.public_ip)
    boundary_controllers = google_compute_instance.boundary_controller.*.network_interface.0.access_config.0.nat_ip
    boundary_database    = google_sql_database_instance.boundary.ip_address.0.ip_address
  })

  filename = "ansible/inventory"
}

output "boundary_psql_password" {
  value = random_id.boundary_psql_password.hex
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "id_rsa"
  file_permission = "0400"
}