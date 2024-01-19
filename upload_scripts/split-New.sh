#!/bin/bash

cd /data-staging/ead_processing/staging/

echo "beginning to process EAD"
#process EADs
for i in *.xml
   do
     /usr/bin/java -jar /home/jovyan/upload_scripts/saxon9he.jar -s:/data-staging/ead_processing/staging/$i -xsl:/home/jovyan/upload_scripts/scrapeEADforPrimo.xsl -o:/data-staging/ead_processing/readyforprimo/`basename "$i"`
   done
   echo "ead processed" 

echo "zipping readyforprimo folder and moving files to correct destination" 
gzip /data-staging/ead_processing/readyforprimo/*.xml
mv /data-staging/ead_processing/readyforprimo/*.xml.gz /data-staging/ead_processing/Primo/getty_data/getty_ead/
mv /data-staging/ead_processing/staging/*.xml /data-staging/ead_processing/readyforoac/
