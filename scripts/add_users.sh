#!/bin/bash

while read -r i; do 
	user="jupyter-"$(echo $i | cut -f 1 -d ,); 
	pw=$(echo $i | cut -f 2 -d ,); 
	echo $user XXX $pw; 
	echo -e "${pw}\n${pw}\n" | passwd $user
done < $1 
