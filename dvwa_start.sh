
# START DOCKER DAEMON
sudo systemctl restart docker.service

# RETRIEVE DVWA
# sudo docker pull vulnerables/web-dvwa
# sudo docker pull httpd

# FIRST RUN
# sudo docker run -it -p 80:80 vulnerables/web-dvwa
# sudo docker run -it -p 8666:80 httpd

# FOLLOWING RUN
sudo docker restart gifted_shirley
sudo docker restart sad_wescoff

# ACCESS RUNNING CONTAINER BASH
# sudo docker exec -it gifted_shirley bash
# sudo docker exec -it sad_wescoff bash

# STOP DOCKER DAEMON
#sudo systemctl stop docker.service

