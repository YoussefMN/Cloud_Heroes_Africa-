#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
echo "Hello Cloud Heroes Africa !" > /var/www/html/index.html
