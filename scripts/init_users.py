import mechanize
import sys
import urllib.request
import csv

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
