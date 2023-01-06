#!/bin/bash

CURRENTUSER=$( id -un )

if [ $CURRENTUSER != "root" ]; then
echo "$0 must be run as root";
exit 1;
fi

INSTALLED_RELEASE=` minio -v | grep -o -P 'RELEASE.+\s' | tr -s ''`

MINIO_BIN_URL="https://s3test.bluebridge.lt/tested-minio/minio"
MINIO_BIN_SHA256="https://s3test.bluebridge.lt/tested-minio/minio.sha256"

CURRENT_MINIO_SHA256SUM=`curl $MINIO_BIN_SHA256`
CURRENT_MINIO_SHA256SUM=`echo $CURRENT_MINIO_SHA256SUM | cut -d ' ' -f 1`

INSTALLED_MINIO_SHA256SUM=`sha256sum /usr/local/bin/minio`
INSTALLED_MINIO_SHA256SUM=`echo $INSTALLED_MINIO_SHA256SUM | cut -d ' ' -f 1`

if [ $CURRENT_MINIO_SHA256SUM != $INSTALLED_MINIO_SHA256SUM ]; then
    echo "New MINIO realese exists and will be downloaded"
    rm -f minio
    wget https://dl.min.io/server/minio/release/linux-amd64/minio
    chmod +x minio

    echo "$CURRENT_MINIO_SHA256SUM minio" > minio.sha256sum


    if sha256sum -c minio.sha256sum | grep -q ': OK' ; then
    echo "copiing new Minio "

    #mkdir -p old_minio/$INSTALLED_RELEASE
    #cp -f /usr/local/bin/minio old_minio/$INSTALLED_RELEASE
    #echo $INSTALLED_RELEASE > old_minio/pre_version

    setcap 'cap_net_bind_service=+ep' /usr/local/bin/minio
    cp -f minio /usr/local/bin/ && systemctl restart minio

    #gzip old_minio/$INSTALLED_RELEASE/minio

    fi
else
    echo "You have latest version of MINIO binary on your system"
fi

