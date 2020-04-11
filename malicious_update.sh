#!/bin/bash

container_name="zealous_chatelet"

# STOPPING HTTPD
sudo docker stop $container_name

# SETTING UP MALICIOUS WEB SERVER
sudo docker cp malicious_server/. $container_name:/var/www/html

# STARTING HTTPD
sudo docker start $container_name

