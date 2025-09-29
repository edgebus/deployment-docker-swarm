#!/bin/bash

CA_NAME=$(yq --raw-output '.services.traefik.environment.CA_NAME' stack.local.yml)
COMMON_NAME=$(yq --raw-output '.services.traefik.environment.COMMON_NAME' stack.local.yml)
COUNTRY=$(yq --raw-output '.services.traefik.environment.COUNTRY' stack.local.yml)
STATE=$(yq --raw-output '.services.traefik.environment.STATE' stack.local.yml)
ORGANIZATION=$(yq --raw-output '.services.traefik.environment.ORGANIZATION' stack.local.yml)
ORGANIZATION_UNIT=$(yq --raw-output '.services.traefik.environment.ORGANIZATION_UNIT' stack.local.yml)
EMAIL_ADDRESS=$(yq --raw-output '.services.traefik.environment.EMAIL_ADDRESS' stack.local.yml)
ROOT_DOMAIN=$(yq --raw-output '.services.traefik.environment.ROOT_DOMAIN' stack.local.yml)

cd ~/deployment-docker-swarm/traefik-deployment/etc/devel

openssl genrsa -out $CA_NAME.key 4096
openssl req -new -x509 -days 3650 -subj "/C=$COUNTRY/ST=$STATE/L=$STATE/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL_ADDRESS" -key $CA_NAME.key -out $CA_NAME-certificate.crt
openssl req -new -subj "/C=$COUNTRY/ST=$STATE/L=$STATE/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL_ADDRESS" -key $CA_NAME.key -out server.csr

echo "subjectAltName = @alt_names

[alt_names]
DNS.1 = $ROOT_DOMAIN
DNS.2 = *.$ROOT_DOMAIN" > ~/deployment-docker-swarm/traefik-deployment/misc/v3ext-gen.sh

openssl x509 -req -in server.csr -CA $CA_NAME-certificate.crt -CAkey $CA_NAME.key -CAcreateserial -extfile ~/deployment-docker-swarm/traefik-deployment/misc/v3ext-gen-test.sh -out $CA_NAME-server.crt -days 3650 -sha256

echo "Додайте сертифікат сервера у довірені для свого веб-браузера, та системи."