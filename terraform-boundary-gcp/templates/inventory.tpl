[all:vars]
boundary_tls_disable=true

[boundary_controllers]
%{ for controller in boundary_controllers ~}
${ controller } boundary_psql_endpoint='${boundary_database}:5432'
%{ endfor ~}

[boundary_workers]
%{ for worker in boundary_workers ~}
${ worker }
%{ endfor ~}