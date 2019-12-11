FROM ubuntu:18.04
RUN apt-get update && apt-get install -y python3-dev python3-pip
RUN pip3 install --upgrade pip
RUN pip3 install torch --no-cache-dir
RUN pip3 install torchvision --no-cache-dir
WORKDIR /app
COPY mnist /app
RUN mkdir logs
CMD python3 -m cProfile -o /logs/cprofile_log main.py --epochs 1 > /logs/train_log
