# Adapted from scipy-notebook by the Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_CONTAINER=$REGISTRY/$OWNER/scipy-notebook
FROM --platform=linux/amd64 $BASE_CONTAINER

USER root

#install Ruby, gems, and bundler for Aspace-Export-Service app 
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get install -y ruby && \
    gem install bundler && \
    apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

ARG NEXUS_USER
ARG NEXUS_PASSWORD
ARG PIP_INDEX_URL=https://${NEXUS_USER}:${NEXUS_PASSWORD}@artifacts.getty.edu/repository/jpgt-pypi-virtual/simple

LABEL maintainer="Ben O'Steen <bosteen@getty.edu>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Getty specific libraries on top of the scipy stack:
RUN pip install --no-cache-dir celery==5.3.* \
boto3 \
#for METS splitting tool 
panel \
metstools \ 
rad-search-library==1.7.4 \
SPARQLWrapper==1.8.* \
atlassian-python-api==3.22.* \
lodgatewayclient==3.2.0 \
idmanagerclient==2.1.3 \
aspace_api_transform==2.6.2 \
otmmapiclient==1.2.32 \
tmsclient==1.0.3 \
contentstackclient==1.0.2 \
linkedart-py==1.0.1 \
archesapiclient==1.1.9 && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

#copy in ead_processing folder for upload portion of notebook 
COPY upload_scripts upload_scripts/

#create mounted data directories
RUN mkdir /data-staging && chown ${NB_UID} /data-staging

USER ${NB_UID}

WORKDIR /home/jovyan

#unzip copy of exporter app for IA process, rename, and remove zip
RUN wget https://github.com/hudmol/archivesspace_export_service/releases/download/1.5/archivesspace_export_service-v1.5.zip && \
    unzip archivesspace_export_service-v1.5.zip && \ 
    mv archivesspace_export_service archivesspace_export_service_IA/ && \
    rm archivesspace_export_service-v1.5.zip

#unzip second copy for SC process and remove zip 
RUN wget https://github.com/hudmol/archivesspace_export_service/releases/download/1.5/archivesspace_export_service-v1.5.zip && \
    unzip archivesspace_export_service-v1.5.zip  && \
    rm archivesspace_export_service-v1.5.zip

#copy in necessary files/updates for SC and IA 
COPY config/* archivesspace_export_service/exporter_app/config/
COPY job_state_storage.rb archivesspace_export_service/exporter_app/lib/
COPY sc_export_app_files/log_manager.rb archivesspace_export_service/exporter_app/lib/
COPY sc_export_app_files/export_ead_task.rb archivesspace_export_service/exporter_app/tasks/
COPY sc_export_app_files/exporter_app.rb archivesspace_export_service/exporter_app/

#IA
COPY config_ia/* archivesspace_export_service_IA/exporter_app/config/
COPY job_state_storage.rb archivesspace_export_service_IA/exporter_app/lib/
COPY ia_export_app_files/log_manager.rb archivesspace_export_service_IA/exporter_app/lib/
COPY ia_export_app_files/export_ead_task.rb archivesspace_export_service_IA/exporter_app/tasks/
COPY ia_export_app_files/exporter_app.rb archivesspace_export_service_IA/exporter_app/

