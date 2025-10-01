#!/bin/sh

# TODO: remove
apk add openssl

if ! command -v openssl >/dev/null 2>&1; then
    echo "OpenSSL is NOT installed. Cannot generate default certificate for organization '${DEFAULT_CERT_ORGANIZATION}'. Pls, use proper Traefik image for the purpose." >&2
    exit 1
fi

openssl genrsa -out /root/ca.key 4096
openssl genrsa -out /traefik-data/server.key 4096

openssl req -new -x509 -days 3650 -subj \
 "/C=$DEFAULT_CERT_COUNTRY/ST=$DEFAULT_CERT_STATE/L=$DEFAULT_CERT_STATE/O=$DEFAULT_CERT_ORGANIZATION/OU=ololo/OU=kolya/CN=$DEFAULT_CERT_COMMON_NAME/emailAddress=$DEFAULT_CERT_EMAIL_ADDRESS" \
 -key /root/ca.key \
 -out /traefik-data/ca.crt
openssl req -new -subj \
 "/C=$DEFAULT_CERT_COUNTRY/ST=$DEFAULT_CERT_STATE/L=$DEFAULT_CERT_STATE/O=$DEFAULT_CERT_ORGANIZATION/OU=$DEFAULT_CERT_ORGANIZATION_UNIT/CN=$DEFAULT_CERT_COMMON_NAME/emailAddress=$DEFAULT_CERT_EMAIL_ADDRESS" \
 -key /traefik-data/server.key \
 -out /root/server.csr

cat <<EOF > /root/ca-ext.conf
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DEFAULT_CERT_ROOT_DOMAIN
DNS.2 = *.$DEFAULT_CERT_ROOT_DOMAIN
EOF

openssl x509 -req -in /root/server.csr \
  -CA /traefik-data/ca.crt \
  -CAkey /root/ca.key \
  -CAcreateserial \
  -CAserial /root/ca.srl \
  -extfile /root/ca-ext.conf \
  -out /traefik-data/server.crt \
  -days 3650 \
  -sha256

rm /root/ca-ext.conf
rm /root/ca.key
rm /root/ca.srl
rm /root/server.csr

exec "$@"
