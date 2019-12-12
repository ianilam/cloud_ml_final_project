FROM ubuntu:18.04
RUN apt-get update && apt-get install -y python3-dev python3-pip
RUN pip3 install --upgrade pip
RUN pip3 install torch==1.3.1+cpu torchvision==0.4.2+cpu -f https://download.pytorch.org/whl/torch_stable.html --no-cache-dir
RUN apt-get -y update && apt-get -y install time
COPY mnist /

RUN mkdir /logs
CMD time python3 -m cProfile -o /logs/cprofile_log main.py --epochs 1 > /logs/train_log
