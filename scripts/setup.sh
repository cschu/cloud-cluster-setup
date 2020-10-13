#!/bin/bash -e

sudo apt-get update
sudo apt install python3 python3-dev git curl snakemake -y
pip install mechanize
sudo cat << EOS >> /etc/default/useradd
HOME=/vol/spool
EOS


curl -L https://tljh.jupyter.org/bootstrap.py | sudo -E python3 - --admin saturn


sudo cat << EOS >> /opt/tljh/config/config.yaml
user_environment:
  default_app: jupyterlab
limits:
  cpu: 1
  memory: 4G
services:
  cull:
    enabled: false
EOS

# https://tljh.jupyter.org/en/latest/howto/auth/firstuse.html
sudo tljh-config set auth.FirstUseAuthenticator.create_users true
sudo tljh-config reload proxy
sudo tljh-config reload hub

sudo python3 $(dirname $0)/init_users.py saturn pwSWC2020

while read -r i; do
    USER="$(echo "$i" | cut -d, -f1)"
    PASSWORD="$(echo "$i" | cut -d, -f2)"
    sudo python3 $(dirname $0)/init_users.py $USER $PASSWORD
    echo $USER $PASSWORD $(ls -d /vol/spool/*$USER)
done < <(tail -n+2 $(dirname $0)/../data/users)

sudo tljh-config add-item users.admin swc31
sudo tljh-config add-item users.admin swc34

sudo cat << EOS >> /opt/tljh/config/config.yaml
https:
  enabled: true
  letsencrypt:
    email: XXEMAILXX
    domains:
    - XXDOMAINXX
EOS

https_email=$1
https_domain=$2

sudo sed -i "s/XXEMAILXX/$https_email/" /opt/tljh/config/config.yaml
sudo sed -i "s/XXDOMAINXX/$https_domain/" /opt/tljh/config/config.yaml

sudo tljh-config set auth.FirstUseAuthenticator.create_users false 
sudo tljh-config reload proxy
sudo tljh-config reload hub
