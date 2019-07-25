output "instance_ips" {
  value = ["${aws_instance.grimoirelab.*.public_ip}"]
}
