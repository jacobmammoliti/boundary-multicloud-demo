provider "boundary" {
  addr             = "http://34.75.196.113:9200"
  recovery_kms_hcl = <<EOT
kms "aead" {
  purpose   = "recovery"
  aead_type = "aes-gcm"
  key_id    = "global_recovery"
  key       = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
}
EOT
}

resource "boundary_scope" "org" {
  scope_id    = "global"
  name        = "organization"
  description = "Organization scope"

  auto_create_admin_role   = false
  auto_create_default_role = false
}

resource "boundary_scope" "project" {
  name                     = "project"
  description              = "My first project"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = false
  auto_create_default_role = false
}

resource "boundary_auth_method" "password" {
  name        = "my_password_auth_method"
  description = "Password auth method"
  type        = "password"
  scope_id    = boundary_scope.org.id
}

resource "boundary_account" "jacobm" {
  name           = "jacobm"
  description    = "User account for my user"
  type           = "password"
  login_name     = "jacobm"
  password       = "arctiq2021"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_user" "jacobm" {
  name        = "jacobm"
  description = "Jacob Mammoliti"
  account_ids = [boundary_account.jacobm.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_role" "org_admin" {
  scope_id       = "global"
  grant_scope_id = boundary_scope.org.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [boundary_user.jacobm.id]
}

resource "boundary_role" "project_admin" {
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.project.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [boundary_user.jacobm.id]
}

output "auth_method_id" {
  value = boundary_auth_method.password.id
}