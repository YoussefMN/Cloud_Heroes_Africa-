#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
echo "Made with love for Cloud Heroes Africa <3" > /var/www/html/index.html
