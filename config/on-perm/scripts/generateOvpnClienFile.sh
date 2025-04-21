#!/bin/bash

options=$(getopt -o o: --long protocol:,server_ip:,port:,auth:,cipher:,ca_crt:,client_crt:,client_key:,ta_key: -n 'generateOvpnClientFile.sh' -- "$@")

if [ $? -ne 0 ]; then
    echo "Failed to parse options"
    exit 1
fi

eval set -- "$options"

PROTOCOL=""
SERVER_IP=""
PORT=""
AUTH=""
CIPHER=""
CA_CERT=""
CLIENT_CERT=""
CLIENT_KEY=""
TA_KEY=""
OUTPUT_FILE=""

while true; do
    case "$1" in
        --protocol)
            PROTOCOL=$2
            shift 2
            ;;
        --server_ip)
            SERVER_IP=$2
            shift 2
            ;;
        --port)
            PORT=$2
            shift 2
            ;;
        --auth)
            AUTH=$2
            shift 2
            ;;
        --cipher)
            CIPHER=$2
            shift 2
            ;;
        --ca_crt)
            CA_CERT=$2
            shift 2
            ;;
        --client_crt)
            CLIENT_CERT=$2
            shift 2
            ;;
        --client_key)
            CLIENT_KEY=$2
            shift 2
            ;;
        --ta_key)
            TA_KEY=$2
            shift 2
            ;;
        -o)
            OUTPUT_FILE=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$DH" ] || [ -z "$OUTPUT_FILE" ] || [ -z "$TA_KEY" ] || [ -z "$CLIENT_KEY" ] || [ -z "$CLIENT_CERT" ] || [ -z "$CA_CERT" ] || [ -z "$CIPHER" ] || [ -z "$AUTH" ] || [ -z "$PORT" ] || [ -z "$SERVER_IP" ] || [ -z "$PROTOCOL" ]; then
    echo "Missing required arguments. Please provide all the following:"
    echo "--protocol, --server_ip, --port, --auth, --cipher, --ca_crt, --client_crt, --client_key, --ta_key, and -o (output file)
    exit 1
fi

tee $OUTPUT_FILE << EOF
client
dev tun
proto $PROTOCOL
remote $SERVER_IP $PORT
resolv-retry infinite
nobind
persist-key
persist-tun

remote-cert-tls server
auth $AUTH
cipher $CIPHER

<ca>
$(cat $CA_CERT)
</ca>

<cert>
$(cat $CLIENT_CERT)
</cert>

<key>
$(cat $CLIENT_KEY)
</key>

# TLS Auth Key
key-direction 1
<tls-auth>
$(cat $TA_KEY)
</tls-auth>

verb 3
EOF

 
#./generateOvpnClientFile.sh -o /etc/openvpn/fth.ovpn --protocol udp --server_ip 192.168.0.15 --port 1194 --auth SHA256 --cipher AES-256-CBC --ca_crt /etc/openvpn/easy-rsa/pki/ca.crt --client_crt /etc/openvpn/easy-rsa/pki/issued/fth.crt --client_key /etc/openvpn/easy-rsa/pki/private/fth.key --ta_key /etc/openvpn/ta.key