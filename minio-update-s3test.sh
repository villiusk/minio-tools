#!/bin/bash

CURRENTUSER=$( id -un )

if [ $CURRENTUSER != "root" ]; then
echo "$0 must be run as root";
exit 1;
fi

MINIO_BIN_URL="https://s3test.bluebridge.lt/minio1/minio"
INSTALLED_RELEASE=` minio -v | grep -o -P 'RELEASE.+\s' | tr -s ''`
INSTALLED_MD5=`md5sum /usr/local/bin/minio | cut -d " " -f 1`

S3TEST_MD5=`curl -I -s $MINIO_BIN_URL | grep ETag | cut -d ' ' -f 2 | tr -d '"'`

#CURRENT_MINIO_SHA256SUM=`curl https://dl.min.io/server/minio/release/linux-amd64/minio.sha256sum`
#CURRENT_MINIO_SHA256SUM=`echo $CURRENT_MINIO_SHA256SUM | cut -d ' ' -f 1`

#INSTALLED_MINIO_SHA256SUM=`sha256sum /usr/local/bin/minio`
#INSTALLED_MINIO_SHA256SUM=`echo $INSTALLED_MINIO_SHA256SUM | cut -d ' ' -f 1`


echo "Instaled minio MD5: "
echo $INSTALLED_MD5;
echo;
echo "S3test MD5: "
echo $S3TEST_MD5;

if [ $INSTALLED_MD5 != $S3TEST_MD5 ]; then
echo "New version will be installed";

else
echo "System already use latest trusted version from s3test"; 
echo;


fi
