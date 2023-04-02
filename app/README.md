# Application Directory

This directory contains the source code and Dockerfile for the application.

## Prerequisites

- Docker

## Usage

### Running the application locally

To run the application locally using Docker Compose, use the following command:

`make up`

This will start the application and all of its dependencies in a local Docker Compose environment. You can then access the application by visiting `http://localhost:8501` in your web browser.

### Developing the application locally

You can develop the application locally using the Docker Compose environment. Make changes to the source code as necessary, and then run the `make up` command again to see the changes in action.

### Stopping the application

To stop the application and tear down the Docker Compose environment, use the following command:

`make down`

### Building the container

To build the Docker container, use the following command:

`make build`

### Pushing the container to Google Artifact Registry (GAR)

To push the Docker container to GAR, use the following command:

`make push`

Before running this command, make sure you have authenticated with GAR and have the necessary permissions to push to the specified GAR repository.

If you have not pushed an image to GAR before, you may need to run the following command before pushing: `gcloud auth configure-docker asia-northeast1-docker.pkg.dev`. Note that depending on the region you are using, you may need to modify the host accordingly.

## Deploying the container to Cloud Run

To deploy the Docker container to Cloud Run, use the following command:

`make deploy`

Before running this command, make sure you have authenticated with Google Cloud and have the necessary permissions to create and deploy a Cloud Run service.

## Directory Structure

- .docker/Dockerfile: The Dockerfile used to build the Docker container image for the application.
- src/: The source code for the application.
