
container_name="sad_wescoff"

# STOPPING HTTPD
sudo docker stop $container_name

# SETTING UP MALICIOUS WEB SERVER
sudo docker cp malicious/. $container_name:/usr/local/apache2/htdocs

# STARTING HTTPD
sudo docker restart $container_name

# ACCESS RUNNING CONTAINER BASH
# sudo docker exec -it sad_wescoff bash

