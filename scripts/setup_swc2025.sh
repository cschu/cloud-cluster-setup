#!/bin/bash

sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

apt install -y openjdk-19-jre-headless python-is-python3 ffmpeg tree

curl -s https://get.nextflow.io | bash
mv nextflow /usr/local/bin
chmod 755 /usr/local/bin/nextflow

pip install numpy

# echo -e is somehow not working
# sh -c 'echo "alias python=\"python3\"" >> /etc/profile.d/00-aliases.sh'
# sed -i "s/\"/'/g" /etc/profile.d/00-aliases.sh

# not necessary on bibigrid
groupadd docker

# make docker runnable for all
chmod a+x /var/run/docker.sock
systemctl restart docker

mkdir -p /vol/swc2025/
cd /vol/swc2025/
git clone https://github.com/cschu/swc2025_embl_course.git course

# allow user+pw ssh login
#  155  sudo vi /etc/ssh/sshd_config
#  156  sudo vi /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
#  sudo service ssh restart
