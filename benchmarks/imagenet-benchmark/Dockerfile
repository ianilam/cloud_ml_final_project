# Start with a Linux micro-container to keep the image tiny
FROM ubuntu:18.04
#FROM alpine:3.7
# Document who is responsible for this image
# MAINTAINER Seetharami R. Seelam "sseelam@nyu.edu"

# Install just the Python runtime (no dev)
RUN apt-get update && apt-get install -y python3-dev python3-pip
#RUN apk add --no-cache python3 py3-pip ca-certificates
# Expose any ports the app is expecting in the environment
# ENV PORT 8001
# EXPOSE $PORT
RUN pip3 install --upgrade pip
RUN pip3 install torch --no-cache-dir
RUN pip3 install torchvision --no-cache-dir
RUN pip3 install flask
# Set up a working folder and install the pre-reqs
# RUN mkdir app
WORKDIR /app
#ADD pytorch-cli/requirements.txt /app

# Add the code as the last Docker layer because it changes the most
ADD ./app  /app
RUN mkdir logs
# Run the service
CMD python3 main.py -a alexnet -b 8 --epochs 1 --lr 0.01 -j 0 . > /logs/perf.log
