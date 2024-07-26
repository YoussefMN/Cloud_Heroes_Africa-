#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS Community Day Tunisia</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            text-align: center;
        }
        header {
            background-color: #232f3e;
            color: white;
            width: 100%;
            padding: 20px;
            text-align: center;
            position: fixed;
            top: 0;
        }
        .content {
            margin: 20px;
        }
        .content h1 {
            color: #232f3e;
        }
        .content p {
            color: #333;
            font-size: 1.2em;
        }
        .footer {
            position: absolute;
            bottom: 0;
            width: 100%;
            text-align: center;
            padding: 20px;
            background-color: #232f3e;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 20px; /* Adjust the space between images */
        }
        .footer img {
            width: 120px; /* Adjust the size as needed */
            margin: 10px;
        }
        .flag {
            width: 50px; /* Adjust the size as needed */
        }
    </style>
</head>
<body>
    <header>
        <h1>AWS Community Day Tunisia</h1>
    </header>
    <div class="content">
        <h1>Welcome to AWS, Cloud Enthusiasts!</h1>
        <p>We are excited to have you join us for this special day. Together, we will explore the world of Terraform on AWS, learn and build amazing things.</p>
    </div>
</body>
</html>
EOF
systemctl restart httpd
