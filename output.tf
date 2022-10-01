output "ip_private_master" {
  value = aws_instance.mp_master.private_ip
}

output "ip_private_nodes" {
  value = { for k, v in aws_instance.mp_nodes : k => format("%s: %s", k, v.private_ip) }
}

output "ip_public_front" {
  value = aws_eip.mp_master_eip.public_ip
}

output "ip_public_ssh_gateway" {
  value = aws_eip.mp_tool_gateway_eip.public_ip
}

output "efs_dns" {
  value = aws_efs_mount_target.mp_efs_mount_target.dns_name
}
