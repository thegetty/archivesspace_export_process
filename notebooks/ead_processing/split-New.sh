#!/bin/sh

cd /home/jovyan/ead_processing/staging/ 

#process EADs
for i in *.xml
   do
     /usr/bin/java -jar /home/jovyan/ead_processing/saxon9he.jar -s:/home/jovyan/ead_processing/staging/$i -xsl:/home/jovyan/ead_processing/scrapeEADforPrimo.xsl -o:/home/jovyan/ead_processing/readyforprimo/`basename "$i"`
   done
 

