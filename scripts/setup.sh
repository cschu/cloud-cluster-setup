#!/bin/bash -e

sudo apt-get update
sudo apt install python3 python3-dev git curl snakemake -y

# for user-management...
pip install mechanize

# we want user homes sitting in /vol/spool to make use of the shared filesystem
# so that results from the cluster don't need to be copied back into to user home/source directory
sudo cat << EOS >> /etc/default/useradd
HOME=/vol/spool
EOS

# install TLJH
curl -L https://tljh.jupyter.org/bootstrap.py | sudo -E python3 - --admin saturn

# add configuration (do not set up https just yet)
sudo cat << EOS >> /opt/tljh/config/config.yaml
user_environment:
  default_app: jupyterlab
limits:
  cpu: 1
  memory: 2G
services:
  cull:
    enabled: false
EOS

# user management
# first, allow "everybody" to create users 
# (otherwise it will not be possible to auto-generate a list of users via cli)
# https://tljh.jupyter.org/en/latest/howto/auth/firstuse.html
sudo tljh-config set auth.FirstUseAuthenticator.create_users true
sudo tljh-config reload proxy
sudo tljh-config reload hub

# initialise the admin user
sudo python3 $(dirname $0)/init_users.py saturn pwSWC2020

wget http://swcarpentry.github.io/shell-novice/data/data-shell.zip
unzip data-shell.zip

# read the user data from csv
# for each record, use init_users.py (via mechanize) to activate users via 'logging in'
# this will also generate the home directories (in /vol/spool)
while read -r i; do
    USER="$(echo "$i" | cut -d, -f1)"
    PASSWORD="$(echo "$i" | cut -d, -f2)"
    JUHOME=/vol/spool/jupyter-$USER

    sudo python3 $(dirname $0)/init_users.py $USER $PASSWORD

    sudo touch $JUHOME/.bashrc
    sudo echo "PS1='$ '" >> $JUHOME/.bashrc
    sudo cp data-shell $JUHOME/
    sudo chown -R $USER:$USER $JUHOME

    echo $USER $PASSWORD $(ls -d $JUHOME)
done < <(tail -n+2 $(dirname $0)/../data/users)

rm -rf data-shell data-shell.zip

# set additional admin users (Renato and me)
# https://tljh.jupyter.org/en/latest/howto/admin/admin-users.html
# TODO: this might be doable before users are added, which would prevent locking them out of sudo while they're logged in
sudo tljh-config add-item users.admin swc31
sudo tljh-config add-item users.admin swc34

# now add https information 
# the required email and domain are provided as cmd args $1 and $2
# that way, even if the pws are hardcoded, the cluster remains hidden from view
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

# deactivate user-creation via login and restart TLJH services
sudo tljh-config set auth.FirstUseAuthenticator.create_users false 
sudo tljh-config reload proxy
sudo tljh-config reload hub
