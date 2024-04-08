#!/usr/bin/env bash

# Detect if we are on mac or should use GNU base64 options
case `uname` in
        Darwin)
            b64_opts='-b=0'
            ;; 
        *)
            b64_opts='--wrap=0'
esac

#go get -v -u github.com/cloudflare/cfssl/cmd/...

mkdir pki/

export PURPOSE=metrics
openssl req -x509 -sha256 -new -nodes -days 365 -newkey rsa:2048 -keyout pki/${PURPOSE}-ca.key -out pki/${PURPOSE}-ca.crt -subj "/CN=ca"
echo '{"signing":{"default":{"expiry":"43800h","usages":["signing","key encipherment","'${PURPOSE}'"]}}}' > "pki/${PURPOSE}-ca-config.json"

export SERVICE_NAME=custom-metrics-apiserver
export ALT_NAMES='"custom-metrics-apiserver.custom-metrics","custom-metrics-apiserver.custom-metrics.svc"'
echo '{"CN":"'${SERVICE_NAME}'","hosts":['${ALT_NAMES}'],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=pki/metrics-ca.crt -ca-key=pki/metrics-ca.key -config=pki/metrics-ca-config.json - | cfssljson -bare pki/apiserver

cat <<-EOF > manifests/cm-adapter-serving-certs.yaml
apiVersion: v1
kind: Secret
metadata:
  name: cm-adapter-serving-certs
  namespace: custom-metrics
data:
  serving.crt: $(cat pki/apiserver.pem | base64 ${b64_opts})
  serving.key: $(cat pki/apiserver-key.pem | base64 ${b64_opts})
EOF
