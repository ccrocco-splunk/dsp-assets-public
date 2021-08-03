#!/bin/bash

# make sure your root user
[[ $(id -u) -eq 0 ]] || exec sudo su

# download latest version of DSP
wget -c https://download.splunk.com/products/dsp/releases/1.2.1/linux/dsp-1.2.1-linux-amd64.tar

#wait

echo "DSP download complete, beginning install"

# untar and start install
tar xvf dsp-1.2.1-linux-amd64.tar

wait

cd dsp-1.2.1-linux-amd64

# install with correct flavor and volume mounts

./install --accept-license $@

wait

# get public ip of DSP_HOST

pub_ip="$(curl ifconfig.me)"

echo "The IP that will be used for the DSP_HOST is: $pub_ip"

wait

DSP_HOST=$pub_ip ./configure-ui

wait

cat << EOF > ~/.scloud.toml
env = "prod"
host-url = "https://$DSP_HOST:31000"
auth-url = "https://$DSP_HOST:31000"
tenant = "default"
username = "dsp-admin"
insecure = true
EOF

wait

./deploy

wait

creds="$(./print-login)"

printf "Your DSP cluster is ready for you! Go check it out at https://$pub_ip:30000. $creds"
