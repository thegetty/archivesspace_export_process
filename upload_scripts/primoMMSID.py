import json
import requests
import time
import csv
import shutil, os
import re
import json
import markdown
import logging
import time
import requests
from datetime import date
from datetime import datetime
from datetime import timedelta
from bs4 import BeautifulSoup
import subprocess

#os.makedirs(os.path.dirname("/data-staging/ead_processing/Primo/getty_data/getty_ead/"))
staging_path = '/data-staging/ead_processing/staging/'
d = date.today()

def read_secrets() -> dict:
    filename = "/home/jovyan/upload_scripts/secrets.json"
    try:
        with open(filename, mode='r') as f:
            return json.loads(f.read())
    except FileNotFoundError:
        return {}
secrets = read_secrets()



baseURL = secrets['baseURL']
user = secrets['user']
password = secrets['password']
repositorysc = secrets['repositorysc']
repositoryia = secrets['repositoryia']

auth = requests.post(baseURL + '/users/' + user + '/login?password=' + password).json()
session = auth['session']
headers = {'X-ArchivesSpace-Session': session,
           'Content_Type': 'application/json'}

list_of_recs = []

with open('/data-staging/ead_processing/new_records.csv', newline='\n') as file:
        mmsid_data = csv.reader(file)
        for row in mmsid_data:
                list_of_recs.append({row[0]:row[1]+'.xml'})

no_mmsid = []

print(len(list_of_recs))

for rec in list_of_recs:
	uri_num = list(rec.keys())[0]
	filename = "/data-staging/ead_processing/staging/" + rec[uri_num]
	f = open(filename, 'rb')
	data = f.read()
	soup = BeautifulSoup(data, features="xml")
	endpointsc = '/repositories/' + repositorysc + '/resources/' + uri_num
	output = requests.get(baseURL + endpointsc, headers=headers).json()
	if len(output) > 1:
		try:
			mms_id = output['user_defined']['integer_1']
			soup.find('eadid')['identifier'] = mms_id
			new_f = open(filename, "w")
			new_f.write("".join([ele.strip() for ele in str(soup).split("\n")]))
			new_f.close()  
		except KeyError:
			print("Record missing MMS ID: " + uri_num + "; " + rec[uri_num])
			no_mmsid.append("Record missing MMS ID: " + uri_num + "; " + rec[uri_num])
	else:
		endpointia = '/repositories/' + repositoryia + '/resources/' + uri_num
		output = requests.get(baseURL + endpointia, headers=headers).json()
		try:
			mms_id = str(output['user_defined']['integer_1'])	
			soup.find('eadid')['identifier'] = mms_id
			new_f = open(filename, "w")
			new_f.write("".join([ele.strip() for ele in str(soup).split("\n")]))
			new_f.close()
		except KeyError:
			print("Record missing MMS ID: " + uri_num + "; " + rec[uri_num])
			no_mmsid.append("Record missing MMS ID: " + uri_num + "; " + rec[uri_num])
	f.close()

# with open("no_mmsid.csv", "w", newline="\n") as csv_f:
# 	writer = csv.writer(no_mmsid)

with open(f"/data-staging/ead_processing/logs/no_mmsid_{d}.txt", "w") as f:
    for i in no_mmsid:
        f.write("%s\n" % i)
