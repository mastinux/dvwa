
# START DOCKER DAEMON
sudo systemctl restart docker.service

# CLEAN DANGLING IMAGES
if [ $(`sudo docker images -f "dangling=true" -q` | wc -l) -ne 0 ]; 
then
	sudo docker rmi $(sudo docker images -f "dangling=true" -q)
fi

# RETRIEVE IMAGES
# sudo docker pull vulnerables/web-dvwa
# sudo docker pull php:7.4.0-apache

# FIRST RUN
# sudo docker run -it -p 80:80 vulnerables/web-dvwa
# sudo docker run -it -p 8777:80 php:7.4.0-apache

# FOLLOWING RUN
sudo docker restart gifted_shirley
sudo docker restart zealous_chatelet

# ACCESS RUNNING CONTAINER BASH
# sudo docker exec -it gifted_shirley bash
# sudo docker exec -it zealous_chatelet bash

# STOP DOCKER DAEMON
#sudo systemctl stop docker.service
