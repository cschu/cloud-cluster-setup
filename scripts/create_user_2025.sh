#!/bin/bash

user=$1
pw=$2

home=/vol/swc2025/home/${user}
swc_home=${home}/swc

echo "user=${user} password=${pw}"

adduser --home ${home} --disabled-password --gecos "" ${user}
echo -e "${pw}\n${pw}\n" | passwd ${user}
gpasswd -a ${user} docker

mkdir -p ${swc_home}/
chown ${user}:${user} ${swc_home}

ln -s /vol/swc2025/course/bin ${swc_home}/
ln -s /vol/swc2025/course/data ${swc_home}/

mkdir ${home}/.nextflow
cp -v cloud-cluster-setup/data/nextflow.config ${home}/.nextflow/config
chown -R ${user}:${user} ${home}/.nextflow
