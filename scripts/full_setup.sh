#!/bin/bash -e
# passwords are in cleartext, but this doesn't matter as we're building a throwaway cluster
# and nobody knows where :P

# I got this running with information from these:
# http://sysadm.mielnet.pl/building-and-installing-rpm-slurm-on-centos-7/
# https://gist.github.com/DaisukeMiyamoto/d1dac9483ff0971d5d9f34000311d312 
# https://wiki.fysik.dtu.dk/niflheim/Slurm_database
# https://aws.amazon.com/blogs/compute/enabling-job-accounting-for-hpc-with-aws-parallelcluster-and-amazon-rds/
# https://elwe.rhrk.uni-kl.de/documentation/accounting.html#slurm-jobcomp-configuration
# https://www.linuxbabe.com/mariadb/install-mariadb-ubuntu-18-04-18-10
# 
# https://slurm.schedmd.com/accounting.html#slurmdbd-configuration
# https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-ubuntu-20-04
# https://github.com/B-UMMI/INNUENDO/wiki/4.-Setting-up-SLURM-partitions-and-nodes
# https://www.liquidweb.com/kb/how-to-install-mariadb-5-5-on-ubuntu-14-04-lts/

sudo apt update
sudo apt install slurmdbd mariadb-server python3 python3-dev git curl snakemake -y
sudo systemctl start mariadb	    
sudo systemctl enable mariadb	    
# is this required?
# look at this: https://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script
# sudo mysql_secure_installation 	   

echo "Setting up slurm_acct_db..."
sudo mysql -u root -e "set global innodb_lock_wait_timeout = 900; set global innodb_buffer_pool_size = 1000000000; grant all on slurm_acct_db.* TO 'slurm'@'localhost' identified by 'slurmPW2020' with grant option; create database slurm_acct_db;"
# sudo mysql slurm_acct_db	   

echo "Setting up log access for slurmdbd..."
sudo touch /var/log/slurm-llnl/slurmdbd.log	   
sudo chown slurm:slurm /var/log/slurm-llnl/slurmdbd.log	   

echo "Setting up access to slurmdbd.pid..."
sudo mkdir -p /run/slurmdbd
sudo chown slurm:slurm /run/slurmdbd
# sudo chown slurm:slurm /run/slurmdbd/slurmdbd/slurmdbd.pid


# no idea whether this is needed (or even doing anything)? 
# from http://sysadm.mielnet.pl/building-and-installing-rpm-slurm-on-centos-7/
sudo cat << EOS >> ~/.my.cnf
[client]
password = aksjdlowjedjw34dwnknxpw93e9032edwxbsx

[mysqld]
innodb_buffer_pool_size = 1024M
innodb_log_file_size = 64M
innodb_lock_wait_timeout = 900
EOS

echo "Adding slurmbdbd.conf..."
sudo cat << EOS > /etc/slurm-llnl/slurmdbd.conf
AuthType=auth/munge
DbdAddr=localhost
DbdHost=localhost
SlurmUser=slurm
DebugLevel=debug5
LogFile=/var/log/slurm-llnl/slurmdbd.log
PidFile=/run/slurmdbd/slurmdbd.pid
StorageType=accounting_storage/mysql
StorageHost=localhost
StoragePass=slurmPW2020
StorageUser=slurm
StorageLoc=slurm_acct_db
ArchiveEvents=yes
ArchiveJobs=yes
ArchiveResvs=yes
ArchiveSteps=no
ArchiveSuspend=no
ArchiveTXN=no
ArchiveUsage=no
EOS

echo "Editing slurm.conf..."
sudo cat << EOS >> /etc/slurm-llnl/slurm.conf

AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageHost=localhost
JobAcctGatherType=jobacct_gather/linux
JobAcctGatherFrequency=30
EOS

echo "Renaming partition..."
sudo sed -i "s/PartitionName=debug/PartitionName=swc/" /etc/slurm-llnl/slurm.conf

#sudo systemctl stop slurmdbd	   
echo "Editing slurmdbd.service and reloading daemon..."
sudo sed -i "s/slurmdbd.pid/slurmdbd\/slurmdbd.pid/" /lib/systemd/system/slurmdbd.service
sudo systemctl daemon-reload

echo "start/restart slurmdbd service and creating cluster record in accounting database..."
sudo systemctl start slurmdbd	   
sudo systemctl enable slurmdbd	   
sudo sacctmgr create cluster Name=bibigrid -i 
sudo systemctl restart slurmctld.service slurmd.service slurmdbd.service

sudo systemctl status slurmdbd	   
# sudo slurmdbd -D -vvv	  

echo "Setting user homes to /vol/spool..."
sudo cat << EOS >> /etc/default/adduser
DHOME=/vol/spool
EOS

curl -L https://tljh.jupyter.org/bootstrap.py | sudo -E python3 - --admin saturn
