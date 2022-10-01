resource "aws_route53_zone" "private_zone" {
  name = "srv.mayaprotect.ovh"
  vpc {
    vpc_id = aws_vpc.mp_vpc.id
  }
  depends_on = [
    aws_vpc.mp_vpc
  ]
}

resource "aws_route53_zone" "public_zone" {
  name = "mayaprotect.ovh"
}

resource "aws_route53_record" "r53_master_node_record" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "master"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.mp_master.private_ip]
  depends_on = [
    aws_instance.mp_master
  ]
}

resource "aws_route53_record" "r53_node_records" {
  for_each = var.instances_node
  zone_id  = aws_route53_zone.private_zone.zone_id
  name     = each.value.name
  type     = "A"
  ttl      = "300"
  records  = [aws_instance.mp_nodes[each.key].private_ip]
  depends_on = [
    aws_instance.mp_nodes
  ]
}

resource "aws_route53_record" "r53_public_ssh_gateway_record" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "gateway"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.mp_tool_gateway_eip.public_ip]
  depends_on = [
    aws_eip.mp_tool_gateway_eip
  ]
}

resource "aws_route53_record" "r53_public_www" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "www"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.mp_master_eip.public_ip]
  depends_on = [
    aws_eip.mp_master_eip
  ]
}

resource "aws_route53_record" "r53_public_devel" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "devel"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.mp_master_eip.public_ip]
  depends_on = [
    aws_eip.mp_master_eip
  ]
}

resource "aws_route53_record" "r53_public_root" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = ""
  type    = "A"
  ttl     = "300"
  records = [aws_eip.mp_master_eip.public_ip]
  depends_on = [
    aws_eip.mp_master_eip
  ]
}

resource "aws_route53_record" "r53_public_api" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "api"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.mp_master_eip.public_ip]
  depends_on = [
    aws_eip.mp_master_eip
  ]
}

resource "aws_route53_record" "r53_public_devel_api" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "devel.api"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.mp_master_eip.public_ip]
  depends_on = [
    aws_eip.mp_master_eip
  ]
}
