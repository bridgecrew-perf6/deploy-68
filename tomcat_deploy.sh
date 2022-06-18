#!/bin/bash
#
# test ansible configuration in docker container

export ENVIRONMENT=$1

usage() {
    echo "Usage:  $0 <ENVIRONMENT>"
    exit 1
}

if [ $# -ne 1 ]
then
    usage
fi

echo ""
echo "build docker image"
echo "---------------------------------"
docker build -t myapp .
echo ""

echo ""
echo "launch container"
echo "---------------------------------"
docker run --name myapp_container --rm -dt -p 8080:80/tcp --privileged=true -v ${PWD}:/data myapp /usr/sbin/init
echo ""

echo ""
echo "update repo in docker container"
echo "---------------------------------"
#docker exec -it myapp_container python --version 
docker exec -it myapp_container yum update -y
docker exec -it myapp_container ip link
echo ""

echo ""
echo "install curl ansible in docker container"
echo "---------------------------------"
docker exec -it myapp_container yum install -y epel-release
docker exec -it myapp_container yum install -y curl ansible
docker exec -it myapp_container ansible-galaxy collection install ansible.posix
echo ""

echo ""
echo "execute tomcat_test.sh in docker container"
echo "---------------------------------"
docker exec -it myapp_container /bin/bash data/tomcat_test.sh ${ENVIRONMENT}
echo ""
