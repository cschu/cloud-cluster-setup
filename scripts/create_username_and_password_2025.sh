#!/bin/bash

# i=0; for l in $(sort user_emails.txt); do i=$((i+1)); printf "%s\tswc20251_%02d\tPWD_swc20251_%02d\n" $l ${i} ${i}; done


for i in {1..30}; do
  printf "user_%02d\tswc20251_%02d\tPWD_swc20251_%02d\n" "${i}" "${i}" "${i}";
done
