#winget install -e --id ShiningLight.OpenSSL



#Company Name or ID
$Company = ""
#Certificates can be imported to FG with Import>Certificate>Certificate where you need the crt, key and password



New-Item -ItemType Directory -Path C:\certs




#Generate root private key:
openssl genrsa -aes256 -out clientid_root_private.key 2048

#Generate root CA certificate (This cert should be used in the Windows Trusted Root Certificate Authority):
openssl req -new -x509 -days 3650 -extensions v3_ca -key clientid_root_private.key -out clientid_root_ca.crt

#Service Domain or IP: 
#Generate private key for each service:
openssl genrsa -aes256 -out clientid_service1_private.key 2048

#Generate CSR from service specific private key (Skip challenge and company):
openssl req -new -key clientid_service1_private.key -out clientid_service1.csr

#Generate certificate from CSR using Root CA (ext config file is for alternative names dns/ip):
openssl x509 -req -in clientid_service1.csr -CA clientid_root_ca.crt -CAkey clientid_root_private.key -CAcreateserial -out clientid_service1.crt -days 3650 -sha256 -extfile clientid_service1.ext



========== extfile========== 
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = vpn.domain.com
IP.1 = 123.123.1.1
=========================
