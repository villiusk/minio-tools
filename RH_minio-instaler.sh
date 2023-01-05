#!/bin/bash

MINIOUSER="minio-user"

CURRENTUSER=$( id -un )

if [ $CURRENTUSER != "root" ]; then
echo "$0 must be run as root";
exit 1;
fi

#debian / ubuntu
dnf install epel-release -y
dnf install wget curl certbot -y

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


#config file vars
if [ ! -f /etc/default/minio ]; then
    echo "creating minio config file ..."
    echo "#minio config" >> /etc/default/minio
    echo "MINIO_ROOT_USER=bbadmin" >> /etc/default/minio
    echo "MINIO_ROOT_PASSWORD=passwd-to-change" >> /etc/default/minio
    echo; >>  /etc/default/minio
    echo; >>  /etc/default/minio

    echo '#MINIO_SERVER_URL="https://yuo_server_ip_or_FQDN:80" #consle problems you will need to set vis' >>  /etc/default/minio

    echo; >>  /etc/default/minio
    echo "MINIO_VOLUMES=\"/mnt/disk1/tenant1\"" >> /etc/default/minio

    echo "#SSL example" >> /etc/default/minio
    echo  "#MINIO_OPTS=\"--certs-dir /home/${MINIOUSER}/.minio/certs --address s3test.domainname:443 --console-address :9001\"" >> /etc/default/minio
    echo "MINIO_OPTS=\"--address :80 --console-address :9001\"" >> /etc/default/minio

    echo; >>  /etc/default/minio
    echo; >>  /etc/default/minio
    echo "#MINIO_PROMETHEUS_URL=\"http://localhost:9090\"" >> /etc/default/minio
    echo "#MINIO_PROMETHEUS_JOB_ID=\"minio-job\"" >> /etc/default/minio


    chown $MINIOUSER.$MINIOUSER /etc/default/minio

fi
#end config file vars


chown $MINIOUSER.$MINIOUSER /etc/default/minio
chown $MINIOUSER.$MINIOUSER /mnt/disk1/tenant1

if [ ! -f /etc/systemd/system/minio.service ]; then
echo "Will get SystemD unit file"
( cd /etc/systemd/system/; curl -O https://raw.githubusercontent.com/villiusk/minio-tools/main/minio.service)

systemctl daemon-reload

fi


if [ ! -f /usr/local/bin/minio ]; then

echo "Downloading latest MINIO binary"
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
cp minio /usr/local/bin/minio
restorecon -v /usr/local/bin/minio
fi

#firewall
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=80/tcp #for certbot
firewall-cmd --permanent --add-port=9001/tcp # for quick test
firewall-cmd --reload


echo "If you start minio service unit, it should start listen on port 80 and 9001, no SSL"
echo "Then mount disks at /mnt/ don't forget change ownership to minio user"
echo ;
echo "Change passwd in /etc/dafault/minio as minimum"
echo;
echo "If your ip has FQDN fill change that FQDN in renew file to gen Lets Encrypt cert"
echo "Make chages to minio config file to use FQDN and port 443"

