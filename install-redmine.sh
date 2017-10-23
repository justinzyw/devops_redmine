#!/bin/bash

# Fetch the variables
. parm.txt

# function to get the current time formatted
currentTime()
{
  date +"%Y-%m-%d %H:%M:%S";
}

sudo docker service scale devops-redmine=0
sudo docker service scale devops-redminedb=0


echo ---$(currentTime)---populate the volumes---
#to zip, use: sudo tar zcvf devops_redmine_volume.tar.gz /var/nfs/volumes/devops_redmine*
sudo tar zxvf devops_redmine_volume.tar.gz -C /


echo ---$(currentTime)---create redmine database service---
sudo docker service create -d \
--name devops-redminedb \
--network $NETWORK_NAME \
--mount type=volume,source=devops_redminedb_volume,destination=/var/lib/mysql,\
volume-driver=local-persist,volume-opt=mountpoint=/var/nfs/volumes/devops_redminedb_volume \
--replicas 1 \
--constraint 'node.role == manager' \
$REDMINEDB_IMAGE


echo ---$(currentTime)---create redmine service---
sudo docker service create -d \
--publish $REDMINE_PORT:3000 \
--name devops-redmine \
--mount type=volume,source=devops_redmine_volume,destination=/usr/src/redmine/files,\
volume-driver=local-persist,volume-opt=mountpoint=/var/nfs/volumes/devops_redmine_volume \
--network $NETWORK_NAME \
--replicas 1 \
--constraint 'node.role == manager' \
$REDMINE_IMAGE


sudo docker service scale devops-redminedb=1
sudo docker service scale devops-redmine=1
