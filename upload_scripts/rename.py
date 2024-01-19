import shutil, os
import csv
import re
import json
import markdown
import logging
import time
import boto3
from botocore.exceptions import ClientError
from datetime import date
from datetime import datetime
from datetime import timedelta
from bs4 import BeautifulSoup


#Pull in all files in directory
aes_path_SC = "/data-staging/aspace_ead/sc_ead/ead/exported/ead/"
aes_path_IA = "/data-staging/aspace_ead/ia_ead/ead/exported/ead/"
#os.makedirs(os.path.dirname("/data-staging/ead_processing/staging/"))
staging_path = "/data-staging/ead_processing/staging/"
#os.makedirs(os.path.dirname("/data-staging/ead_processing/readyforprimo/"))
primo_path = "/data-staging/ead_processing/readyforprimo/"
#os.makedirs(os.path.dirname("/data-staging/ead_processing/readyforpub/"))
final_path = "/data-staging/ead_processing/readyforpub/"
#os.makedirs(os.path.dirname("/data-staging/ead_processing/readyforoac/"))
oac_path = "/data-staging/ead_processing/readyforoac/"
#os.makedirs(os.path.dirname("/data-staging/ead_processing/logs/"))
logpath = "/data-staging/ead_processing/logs/"
dir_list_SC = os.listdir(aes_path_SC)
dir_list_IA = os.listdir(aes_path_IA)

#set up date
d = date.today()

#setup log file
filename = 'rename' + str(d.isoformat()) + '.log'
logname  = logpath + filename
print("logging to:" + logname)
logging.basicConfig(filename=logname,level=logging.INFO)
main_log = logging.getLogger(__name__)
main_log.setLevel(logging.INFO)
console = logging.StreamHandler()
console.setFormatter(logging.Formatter(' %(message)s'))
main_log.addHandler(console)
console.setLevel(logging.ERROR)

#set up secrets
def read_secrets() -> dict:
    filename = "/home/jovyan/upload_scripts/secrets.json"
    try:
        with open(filename, mode='r') as f:
            return json.loads(f.read())
    except FileNotFoundError:
        return {}
secrets = read_secrets()

#set up s3 connection
s3_client = boto3.client('s3', aws_access_key_id=secrets['ARCHIVES2_AWS_ACCESS_KEY'], aws_secret_access_key=secrets['ARCHIVES2_AWS_SECRET_KEY'])
s3_buckets = ['jpgt-or-stg-rcv']
#'jpgt-or-prd-rcv'

def rename_IA():
	#Define pattern to match the three types of files produced by the plugin that are valid (.xml, .json, .pdf)
	pattern = re.compile("^[0-9]*.xml$|^[0-9]*.json$|^[0-9]*.pdf$")
	#Define pattern to match related files
	group_name = re.compile("(^[0-9]*).")

	#Group all related files into a dictionary
	group_of_files = {}
	for file in dir_list_IA:
		if re.match(pattern,file):
			group_name_match = re.search("(^[0-9]*).", file)
			group_name = group_name_match.groups()[0]
			if group_name in group_of_files.keys():
				group_of_files[group_name].append(file)
			else:
				group_of_files[group_name]=[file]

	#Delete any groups of files from dictionary that don't have three files -- this means that there was an error in the transform & they shouldn't be processed
	list_to_del = []
	for k, v in group_of_files.items():
		if len(v) != 3:
			list_to_del.append(k)
			main_log.error("These resources didn't produce enough files: {} {}".format(k, v))

	for delete in list_to_del:
		del group_of_files[delete]

	updated_filenames = {}
	lines_of_readme= []
	list_of_resources = []
	count = 0
	with open(aes_path_IA + 'README.md', encoding="utf8") as readme:
		text =readme.read()
		html = markdown.markdown(text)
		lines = html.split('\n')
		for line in lines[3:]:
			columns=line.split(' | ')
			try:
				file_number=re.findall('href="([0-9]*).', columns[:1][0])[0]
				try:
					updated_filenames[columns[2:3][0].replace("</em>","").replace("<em>","")] = group_of_files[file_number]
					count += 1
					list_of_resources.append(columns[2:3][0].replace("</em>","") + ' : ' + file_number)
				except KeyError:
					main_log.error("Resource written to readme but doesn't have all required files: {}".format(file_number))
			except IndexError:
				main_log.error("Script can't find resource number: {}".format(columns[:1][0]))

	main_log.info("{} finding aids have been made available for publication".format(count))
	main_log.info("List: {}".format(list_of_resources))

	new_records = []
	last_week = (datetime.now() - timedelta(days=7)).date()
	print("Number of IA files:" +  str(len(updated_filenames)))
	for k, v in updated_filenames.items():
		for file in v:
			old_with_dest = aes_path_IA + file
			filedate = datetime.fromtimestamp(os.path.getctime(old_with_dest))
			if filedate.date() > last_week:
				if file.endswith('.xml'):
					old_xml_with_dest = old_with_dest
					file_num=file.replace(".xml","")
					staging_with_dest_xml = staging_path + k + '.xml'
					print(k +  ',' + staging_with_dest_xml)
					rcv_with_dest_xml = final_path + k + '.xml'
					with open(old_with_dest, 'r') as f:
						data = f.read()
						soup = BeautifulSoup(data, "xml")
						header = soup.eadheader
						try:
							publication = header['findaidstatus']
						except KeyError:
							main_log.error("Key Error with findingaidstatus: {}".format(k))
				if file.endswith('.pdf'):
					old_pdf_with_dest = old_with_dest
					rcv_with_dest_pdf = final_path + k + '.pdf'
		try:
			if publication == 'completed' and filedate.date() > last_week:
				shutil.copyfile(old_xml_with_dest, staging_with_dest_xml)
				shutil.copyfile(old_xml_with_dest, rcv_with_dest_xml )
				shutil.copyfile(old_pdf_with_dest, rcv_with_dest_pdf )
				try:
					for bucket in s3_buckets:
						upload_resource_to_s3(rcv_with_dest_xml, bucket, 'static/ead/{}'.format(os.path.basename(rcv_with_dest_xml)))
						upload_resource_to_s3(rcv_with_dest_pdf, bucket, 'static/pdf/{}'.format(os.path.basename(rcv_with_dest_pdf)))
				except Exception as e:
					main_log.error("Failed to write to S3: {}".format(e))
				new_records.append([file_num, k])
				main_log.error("This resource has been updated and added to Primo, OAC buckets: {}".format(k))
			else:
				main_log.error("Resource has no updates: {}".format(k))
		except KeyError:
			main_log.error("Key Error with findingaidstatus: {}".format(k))
		except:
			pass
	print("Total new IA records: " + str(len(new_records)))
	writer.writerows(new_records)


def rename_SC():
	#Define pattern to match the three types of files produced by the plugin that are valid (.xml, .json, .pdf)
	pattern = re.compile("^[0-9]*.xml$|^[0-9]*.json$|^[0-9]*.pdf$")
	#Define pattern to match related files
	group_name = re.compile("(^[0-9]*).")

	#Group all related files into a dictionary
	group_of_files = {}
	for file in dir_list_SC:
		if re.match(pattern,file):
			group_name_match = re.search("(^[0-9]*).", file)
			group_name = group_name_match.groups()[0]
			if group_name in group_of_files.keys():
				group_of_files[group_name].append(file)
			else:
				group_of_files[group_name]=[file]
	#Delete any groups of files from dictionary that don't have three files -- this means that there was an error in the transform & they shouldn't be processed
	list_to_del = []
	for k, v in group_of_files.items():
		if len(v) != 3:
			list_to_del.append(k)
			main_log.error("These resources didn't produce enough files: {} {}".format(k, v))

	for delete in list_to_del:
		del group_of_files[delete]

	updated_filenames = {}
	lines_of_readme= []
	list_of_resources = []
	count = 0
	with open(aes_path_SC + 'README.md', encoding="utf8") as readme:
		text =readme.read()
		html = markdown.markdown(text)
		lines = html.split('\n')
		for line in lines[3:]:
			columns=line.split(' | ')
			try:
				file_number=re.findall('href="([0-9]*).', columns[:1][0])[0]
				try:
					updated_filenames[columns[2:3][0].replace("</em>","").replace("<em>","")] = group_of_files[file_number]
					count += 1
					list_of_resources.append(columns[2:3][0].replace("</em>", "") + ' : ' + file_number)
				except KeyError:
					main_log.error("Resource written to readme but doesn't have all required files: {}".format(file_number))
			except IndexError:
				main_log.error("Script can't find resource number: {}".format(columns[:1][0]))

	main_log.info("{} finding aids have been made available for publication".format(count))
	main_log.info("List: {}".format(list_of_resources))
	
	new_records = []
	last_week = (datetime.now() - timedelta(days=7)).date()
	print("Number of SC files:" +  str(len(updated_filenames)))
	for k, v in updated_filenames.items():
		for file in v:
			old_with_dest = aes_path_SC + file
			filedate = datetime.fromtimestamp(os.path.getctime(old_with_dest))
			if filedate.date() > last_week:
				if file.endswith('.xml'):
					old_xml_with_dest = old_with_dest
					file_num=file.replace(".xml","")
					staging_with_dest_xml = staging_path + k + '.xml'
					print(k +  ',' + staging_with_dest_xml)
					rcv_with_dest_xml = final_path + k + '.xml'
					with open(old_with_dest, 'r') as f:
						data = f.read()
						soup = BeautifulSoup(data, "xml")
						header = soup.eadheader
						try:
							publication = header['findaidstatus']
						except KeyError:
							main_log.error("Key Error with findingaidstatus: {}".format(k))
				if file.endswith('.pdf'):
					old_pdf_with_dest = old_with_dest
					rcv_with_dest_pdf = final_path + k + '.pdf'
		try:
			if publication == 'completed' and filedate.date() > last_week:
				try:
					shutil.copyfile(old_xml_with_dest, staging_with_dest_xml)
					shutil.copyfile(old_xml_with_dest, rcv_with_dest_xml )
					shutil.copyfile(old_pdf_with_dest, rcv_with_dest_pdf )
				except FileNotFoundError:
					print("Source file not found.")
				except IsADirectoryError:
					print("Destination is a directory.")
				except PermissionError:
					print("Permission denied.")
				except Exception as e:
					print("An error occurred:", str(e))

				try:
					for bucket in s3_buckets:
						upload_resource_to_s3(rcv_with_dest_xml, bucket, 'static/ead/{}'.format(os.path.basename(rcv_with_dest_xml)))
						upload_resource_to_s3(rcv_with_dest_pdf, bucket, 'static/pdf/{}'.format(os.path.basename(rcv_with_dest_pdf)))
				except Exception as e:
					print("error with upload")
					main_log.error("Failed to write to S3: {}".format(e))
				new_records.append([file_num, k])
				main_log.error("This resource has been updated and added to Primo, OAC buckets: {}".format(k))
			else:
				main_log.error("Resource has no updates: {}".format(k))
		except KeyError:
			main_log.error("Key Error with findingaidstatus: {}".format(k))
		except:
			pass

	print("Total new SC records: " + str(len(new_records)))
	writer.writerows(new_records)

def upload_resource_to_s3(file, bucket, destination):
  s3_client.upload_file(file, bucket, destination)

with open('/data-staging/ead_processing/new_records.csv', 'w', newline="\n") as new_rec_file:
	writer = csv.writer(new_rec_file)
	rename_IA()
	rename_SC()


