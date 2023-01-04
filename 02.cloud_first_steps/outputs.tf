output "public_dns_webserver01" {
    value = aws_instance.webserver01.public_dns
}

output "public_dns_webserver02" {
    value = aws_instance.webserver02.public_dns
}