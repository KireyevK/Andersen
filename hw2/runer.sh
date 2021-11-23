#!/usr/bin/bash

docker build -f dokerfiles/ansible -t ansible .

docker run \
	--rm \
	--name ansible \
	-v "$PWD/ansiblefiles/hosts:/etc/ansible/hosts" \
	-v "$PWD/ansiblefiles/playbook.yml:/etc/ansible/playbook.yml" \
	-v "$PWD/flaskAndersen:/home/flaskAndersen" \
	-d \
	 ansible

docker build -f dokerfiles/ssh-server -t sshd .

docker run \
	--rm \
	--name ssh \
	-p8080:8080 \
	-d \
    sshd

docker inspect --format '{{ .NetworkSettings.IPAddress }}' ssh
echo -e "\033[0;31mtype: \033[0;36myes\033[0;31m\npass: \033[0;36mtest\033[0m"
docker exec -it ansible ssh-copy-id test@172.17.0.3

docker exec ansible ansible-playbook /etc/ansible/playbook.yml

wget -qO- localhost:8080
echo 
docker stop ansible ssh
docker rmi ansible sshd
#docker system prune -af
