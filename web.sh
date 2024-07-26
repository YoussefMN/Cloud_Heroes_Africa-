#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
echo "Welcome Tunisia to AWS community day!" > /var/www/html/index.html
