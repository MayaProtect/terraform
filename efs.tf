resource "aws_efs_file_system" "mp_efs" {
  creation_token   = "mayaprotect"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  kms_key_id       = aws_kms_key.mp_efs_key.arn
  tags = {
    Name = "mayaprotect"
  }
}

resource "aws_efs_mount_target" "mp_efs_mount_target" {
  file_system_id = aws_efs_file_system.mp_efs.id
  subnet_id      = aws_subnet.mp_subnet_public.id
  security_groups = [
    aws_security_group.mp_sg_kubernetes.id,
    aws_security_group.mp_ssh_gateway.id
  ]
}

resource "aws_kms_key" "mp_efs_key" {
  description             = "MayaProtect EFS Key"
  deletion_window_in_days = 10
}
