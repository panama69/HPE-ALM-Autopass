#!/bin/sh

echo "Stopping autopass container (if it exists)"
docker stop autopass

echo "Removing autopass container (if it exists)"
docker rm autopass

echo "Removing hpeautopass image (if it exists)"
docker rmi hpeautopass

echo "Building the hpeautopass image"
if [ $1 = "-b" ]; then
	docker build -t hpeautopass .
else
	echo "Skipping 'docker build' as no -b flag provided"
fi

echo "Create the demo-net network"
if [ $(docker network ls|grep -c -w "demo-net") -ge 1 ]; then
    echo "demo-net already exists"
else
    docker network create --ip-range=172.50.1.0/24 --subnet=172.50.0.0/16 demo-net
fi

echo "Starting autopass container"
if [ $(docker images hpeautopass|grep -c -w "hpeautopass") -ge 1 ]; then
	docker run -p 5814:5814 -d -v /var/opt/HPE/HPEAutopass:/var/opt/HP/HP\ AutoPass\ License\ Server --net demo-net --ip=172.50.1.7 --name autopass hpeautopass
else
	echo "*******"
	echo "*******"
	echo "*******  No local image was found."
	echo "*******  If you intended to do a build you must pass the -b arguement to the script"
	echo "*******"
	echo "*******  Pulling the latest image panama69/hpeautopass on the public https://hub.docker.com"
	echo "*******"
	echo "*******"
	docker run -p 5814:5814 -d -v /var/opt/HPE/HPEAutopass:/var/opt/HP/HP\ AutoPass\ License\ Server --net demo-net --ip=172.50.1.7 --name autopass panama69/hpeautopass:latest
fi

echo "No licenses have been added to autopass"
