#!/bin/bash
set -e

echo "Hello World"

# Pull the Docker image from Docker Hub
docker pull namratha3/simple-python-flask-app:latest 

# Run the Docker image as a container
docker run -d -p 5000:5000 namratha3/simple-python-flask-app:latest 