#!/bin/bash


while read -r user_name user_login password; do 
	echo $user_name $user_login $password
	cloud-cluster-setup/scripts/create_user_2025.sh $user_login $password
done < $1
