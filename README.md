# cloud-cluster-setup

**Do not use the `full_setup.sh`, it's not working currently.**

```
git clone https://github.com/cschu/cloud-cluster-setup.git

# slurm accounting first
sudo bash cloud-cluster-setup/scripts/setup_sacct.sh

# tljh last! (we don't want to disrupt the tljh installation with anything)
sudo bash cloud-cluster-setup/scripts/setup.sh <https-account> <domain>

```

`https-account` is the email-address used for `letsencrypt` and `domain` is the domain assigned to the public ip of the instance:

```
https:
  enabled: true
  letsencrypt:
    email: <https-account>
    domains:
    - <domain>
```
