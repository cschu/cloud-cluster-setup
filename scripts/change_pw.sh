#!/bin/bash


# user_01	swc20251_01	PWD_swc20251_01	user@email.tld	60676b79
while read -r u_alias u_id old_pw u_email new_pw; do
	echo -e "${new_pw}\n${new_pw}\n" | passwd $u_id
	break
done < $1
