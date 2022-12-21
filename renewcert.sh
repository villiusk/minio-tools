#!/bin/bash

#This scrip checks if letsencript cert is valid for next 14 days for 
#set MINIO_USER adn DOMAINNAME
#
#source /etc/dafault/minio

DOMAIN_NAME=s3test.bluebridge.lt
MINIO_USER=minio-user

#seconts of 1 day 86400; 14d: 1209600
ISVALID_AFTER=1209600

#service witch use port 80
SERVICE_PORT80="nginx"



if  ! openssl x509 -checkend ${ISVALID_AFTER} -noout -in /home/${MINIO_USER}/.minio/certs/public.crt ; then
echo "Cert will be renew"

#stoping service on 80 port if is set
if [ ! -z ${SERVICE_PORT80+x} ]; then
echo "temporary stoping service  ${SERVICE_PORT80}"
systemctl stop ${SERVICE_PORT80}
fi

certbot certonly --standalone --force-renew \
-d ${DOMAIN_NAME} \
--staple-ocsp -m vilius.kavaliauskas@bluebridge.lt --agree-tos

cp -f /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem /home/${MINIO_USER}/.minio/certs/public.crt
cp -f /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem /home/${MINIO_USER}/.minio/certs/private.key



chown ${MINIO_USER}.${MINIO_USER} /home/${MINIO_USER}/.minio/certs/public.crt
chown ${MINIO_USER}.${MINIO_USER} /home/${MINIO_USER}/.minio/certs/private.key


systemctl restart minio

#starting service on 80 port if is set
if [ ! -z ${SERVICE_PORT80+x} ]; then
echo "starting service  ${SERVICE_PORT80}"
systemctl stop ${SERVICE_PORT80}
fi


else
echo "Cert will be valid for next $((${ISVALID_AFTER}/3600/24))"
fi

