# Developer Notes

- [How to create a valid self signed SSL Certificate?](https://www.youtube.com/watch?v=VH4gXcvkmOY)
- [Build Your Own Certificate Authority on Linux (Self-Signed SSL Certs)](https://youtu.be/PuWdFOOH5lA?si=gd6nIpgL5OBR4PUq)
- Згенерувати приватний ключ Demo.key
- Згенерувати ssl DemoCA.crt сертифікат для агенства DemoCA
- Додати сертефікат DemoCA в довінері сертефікати операційної системи
- Видати сервірний сертифікат от DemoServer.crt
- Запустити traefik використовючи сервірний сертифікат

1. Створення приватного CA ключа
    ```shell
    openssl genrsa -out Demo.key 4096
    ```
2. Створення сертефіката CA
    ```shell
    openssl req -new -x509 -days 3650 -subj "/C=UA/ST=Kyiv/L=Kyiv/O=DemoCA/OU=IT/CN=DemoCA/emailAddress=DemoCA@gmail.com" -key Demo.key -out DemoCA.crt
    ```
3. Створення CSR (Certificate Signing Request)
    ```shell
    openssl req -new -subj "/C=UA/ST=Kyiv/L=Kyiv/O=DemoCA/OU=IT/CN=traefik.mydomain/emailAddress=DemoCA@gmail.com" -key Demo.key -out server.csr
    ```
4. Додаємо SAN (Subject Alternative Name)
    ```shell
    touch /misc/v3ext-gen.sh

    В файлі:
    subjectAltName = @alt_names

    [alt_names]
    DNS.1 = traefik.mydomain
    DNS.2 = *.mydomain
    ```
5. Підписання CSR сертефікатом CA
    ```shell
    openssl x509 -req -in server.csr -CA DemoCA.crt -CAkey Demo.key -CAcreateserial -extfile /misc/v3ext-gen.sh -out DemoServer.crt -days 3650 -sha256
    ```
6. Додаємо CA в систему
    ```shell
    sudo mkdir -p /usr/local/share/ca-certificates
    sudo cp DemoCA.crt /usr/local/share/ca-certificates
    sudo update-ca-certificates
    ```
7. Перевіряємо чи додався сертифікат
    ```shell
    ls -l /etc/ssl/certs/ | grep DemoCA
    ```
8. [Додаємо сертифікат сервера у веб-браузер](chrome://certificate-manager/localcerts/usercerts)
