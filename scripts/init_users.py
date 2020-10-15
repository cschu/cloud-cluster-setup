import mechanize
import sys
import urllib.request
import csv

# https://mechanize.readthedocs.io/en/latest/browser_api.html#the-browser
# this was supposed to happen via curl (unode's script), but didn't work (probably due to too short passwords)
# https://journalxtra.com/linux/howto-pass-data-variables-to-curl-to-autofill-web-forms/

# https://stackoverflow.com/questions/2311510/getting-a-machines-external-ip-address-with-python
external_ip = urllib.request.urlopen('https://ident.me').read().decode('utf8')
url = "http://{ip}/hub/login".format(ip=external_ip)

def init_user(name, password, url):
    br = mechanize.Browser()
    br.open(url)
    form = br.forms()[0]
    form["username"] = name
    form["password"] = password
    x = mechanize.urlopen(form.click(nr=0))
    #print(x.readlines())
    x.close()
    #print("xxxxxxxxxxxx"*10)

init_user(*sys.argv[1:3], url)
