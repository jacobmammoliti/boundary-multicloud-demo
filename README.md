# HashiCorp Boundary Across GCP and AWS
This repository contains the Terraform code to deploy the infrastructure for HashiCorp Boundary across Google Cloud Platform (GCP) and Amazon Web Services (AWS). 

## Architecture Diagram
_coming soon_

## Steps to Deploy
```bash
# Export the required environment variables for AWS authentication
$ export AWS_ACCESS_KEY_ID="REDACTED"

$ export AWS_SECRET_ACCESS_KEY="REDACTED"

# Export the required environment variable for GCP authentication
$ export GOOGLE_CREDENTIALS="REDACTED"

# Create a Terraform variables file
$ cat <<EOF > terraform.tfvars
gcp_project = "REDACTED"
aws_vpc_id  = "REDACTED"
EOF

# Deploy the infrastructure for Boundary
$ terraform apply
...
Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

Outputs:

boundary_psql_password = "602e502f0100bd149ecd5d78fe34e1"

# Install the general Ansible collection
$ ansible-galaxy collection install community.general

# Install the Boundary Ansible role
$ ansible-galaxy install -r ansible/requirements.yml

# Use the generated SSH private key and PostgreSQL password to deploy Boundary on the infrastructure
$ ansible-playbook --private-key id_rsa -i ansible/inventory ansible/boundary.yml \
  --extra-vars "boundary_psql_password='602e502f0100bd149ecd5d78fe34e1'"
...
PLAY RECAP *******************************************************************************************************
34.74.125.145              : ok=15   changed=10   unreachable=0    failed=0    skipped=28   rescued=0    ignored=0   
34.75.248.58               : ok=16   changed=11   unreachable=0    failed=0    skipped=28   rescued=0    ignored=0   
54.161.56.24               : ok=15   changed=10   unreachable=0    failed=0    skipped=28   rescued=0    ignored=0
```

## Authenticate with Boundary
```bash
# Set the address of the Boundary controller
$ export BOUNDARY_ADDR=http://34.74.125.145:9200

# Authenticate to Boundary
$ boundary authenticate password -auth-method-id=ampw_NhJfnxsvRZ -login-name=admin
Password is not set as flag or in env, please enter it now (will be hidden): 

$ boundary targets list -scope-id p_bIBUWA8aKS

Target information:
  ID:             ttcp_vdSvLTPiEz
    Version:      2
    Type:         tcp
    Name:         Development Hosts


$ boundary connect ssh -target-id ttcp_vdSvLTPiEz -username ubuntu -host-id=hsst_6AwHlucFSV
```