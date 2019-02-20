#!/bin/bash

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install httpd stress stress-ng
yum -y update

systemctl enable httpd
systemctl start httpd

cat >> /var/www/html/index.html << EOF
<html>
<head>
<title>Second Launch Configuration</title>
</head>
<body>
<b>Second Launch Configuration</b>
</body>
</html>
EOF

cat >> /var/www/html/healthy.html << EOF
<html>
<head>
<title>Healthy</title>
</head>
<body>
Healthy
</body>
</html>
EOF
