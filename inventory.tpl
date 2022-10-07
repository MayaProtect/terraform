[master]
${ master_ip }

[nodes]
%{ for ip in nodes_ips ~}
${ ip }
%{ endfor }

[gateway]
${ gateway_ip }

[cluster:children]
master
nodes