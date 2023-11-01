# Getty Jupyter Notebooks

A Jupyter Notebook environment, based on JupyterLabs scipy 'docker-stack'. There are a number of Getty-specific client libraries pre-installed to ease working with the infrastructure APIs.

## Get Started

### Using pre-built image

Use the `docker-compose-ecr.yml` docker compose file to retrieve a prebuild image from the Getty ECR  (this requires ECR authentication to be set up beforehand).

(NB Not yet pushed there, may need additional permissions to let the image be 'created' first before things can be pushed to it)

### From source

1. Add Nexus credentials to a `.env.build` file (see .env.build.example to see the two required fields)
2. Either run `docker-compose-build.sh` or run the following:
```
source .env.build
docker compose build --build-arg NEXUS_USER=$NEXUS_USER --build-arg NEXUS_PASSWORD=$NEXUS_PASSWORD 
```
3. `docker compose up -d` to start things up, and go to http://localhost:8888
