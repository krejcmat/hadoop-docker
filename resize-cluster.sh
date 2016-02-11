#!/bin/bash

tag="latest"

# N is the node number of the cluster
N=$1

if [ $# = 0 ]
then
	echo "Please use the node number of the cluster as the argument!"
	exit 1
fi

cd hadoop-master

# change the slaves file
echo "master.krejcmat.com" > files/slaves
i=1
while [ $i -lt $N ]
do
	echo "slave$i.krejcmat.com" >> files/slaves
	((i++))
done 

# delete master container
sudo docker rm -f master 

# delete hadoop-master image
sudo docker rmi krejcmat/hadoop-master:$tag 

# rebuild hadoop-docker image
pwd
sudo docker build -t krejcmat/hadoop-master:$tag .