#!/bin/bash

MINIOUSER="minio-user"

CURRENTUSER=$( id -un )

if [ $CURRENTUSER != "root" ]; then
echo "$0 must be run as root";
exit 1; 
fi

#debian / ubuntu
apt install wget curl certbot -y 

echo "minio user $MINIOUSER"



#functions

get_distribution() {
	lsb_dist=""
	# Every system that we officially support has /etc/os-release
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	# Returning an empty string here should be alright since the
	# case statements don't act unless you provide an actual value
	echo "$lsb_dist"
}

minio_user() {
    results=$(getent passwd $1 | wc -l)

if [  $results -eq 1 ]; then
    echo "yes the user  exists \n continue"
    
else
    echo "No, the user does not exist\n creating user and group"
    useradd -r $1
    groupadd $1
    mkdir -p /home/$1/.minio/certs/CAs
    mkdir -p /mnt/disk1
    mkdir -p /mnt/disk2
    chown $1.$1 -R /home/$1 /mnt/disk1 /mnt/disk2
  
fi
}

minio_user $MINIOUSER

if [ ! -f /etc/default/minio ]; then
echo "creating minio config file ..."
    echo "#minio config" >> /etc/default/minio
    echo "MINIO_ROOT_USER=bbadmin" >> /etc/default/minio
    echo "MINIO_ROOT_PASSWORD=passwd-to-change" >> /etc/default/minio

    
    echo "MINIO_VOLUMES=\"/mnt/disk1/tenant1\"" >> /etc/default/minio
    
    echo "#SSL example" >> /etc/default/minio
    echo  "#MINIO_OPTS=\"--certs-dir /home/minio/.minio/certs --address s3test.domainname:443 --console-address :9001\"" >> /etc/default/minio
    echo "MINIO_OPTS=\"--address :9000 --console-address :9001\"" >> /etc/default/minio
    
    chown $MINIOUSER.$MINIOUSER /etc/default/minio

fi

if [ ! -f /etc/systemd/system/minio.service ]; then
echo "Will get SystemD unit file"
( cd /etc/systemd/system/; curl -O https://raw.githubusercontent.com/villiusk/minio-tools/main/minio.service)

systemctl daemon-reload

fi


if [ ! -f /usr/local/bin/minio ]; then

echo "Downloading latest MINIO binary"
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
mv minio /usr/local/bin/minio
fi



