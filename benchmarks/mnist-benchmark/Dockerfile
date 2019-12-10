FROM python:3.6
WORKDIR /app
COPY mnist /app
RUN pip install -r requirements.txt --no-cache-dir
RUN mkdir /logs
CMD [ "python", "-m", "cProfile", "-o", "/logs/mnist_profile", "main.py", "--epochs", "1" ]
