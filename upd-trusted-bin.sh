
#!/bin/bash

CURRENTUSER=$( id -un )

if [ $CURRENTUSER != "root" ]; then
echo "$0 must be run as root";
exit 1;
fi

MINIO_BIN_URL="https://s3test.bluebridge.lt:443/minio1/minio"
INSTALLED_RELEASE=`/usr/local/bin/minio -v | grep -o -P 'RELEASE.+\s' | tr -s ''`
INSTALLED_MD5=`md5sum /usr/local/bin/minio | cut -d " " -f 1`

S3TEST_MD5=`curl -I -s $MINIO_BIN_URL | grep ETag | cut -d ' ' -f 2 | tr -d '"'`

#clenung MD5
S3TEST_MD5=`echo $S3TEST_MD5 | sed 's/[^a-zA-Z0-9]//g'`
INSTALLED_MD5=`echo $INSTALLED_MD5  | sed 's/[^a-zA-Z0-9]//g'`


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
rm -f minio
systemctl stop minio
wget $MINIO_BIN_URL
cp -f minio /usr/local/bin/

chmod +x /usr/local/bin/minio
setcap 'cap_net_bind_service=+ep' /usr/local/bin/minio

systemctl start minio
#sleep 4
#systemctl status minio




else
echo "System already use latest trusted version from s3test";
echo;


fi

echo "pre rel $INSTALLED_RELEASE"
