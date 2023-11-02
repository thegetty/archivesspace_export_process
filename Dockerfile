# Adapted from scipy-notebook by the Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_CONTAINER=$REGISTRY/$OWNER/scipy-notebook
FROM $BASE_CONTAINER

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
rad-search-library==1.7.4 \
SPARQLWrapper==1.8.* \
atlassian-python-api==3.22.* \
lodgatewayclient==3.2.0 \
idmanagerclient==2.1.3 \
aspace_api_transform==2.7.1 \
otmmapiclient==1.2.32 \
tmsclient==1.0.3 \
contentstackclient==1.0.2 \
linkedart-py==1.0.1 \
archesapiclient==1.1.9 && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
