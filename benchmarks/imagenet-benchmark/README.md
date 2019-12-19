For each benchmark:

To get the output log file, mount the logs using "docker run -v" as following:
```bash
cd <benchmark_dir>/  
docker build -t <your_tag> .  
docker run -v <your_log_path>:/logs <your_tag>
```

If you want to try it without docker, use:
```
python3 app/main.py -a alexnet -b 8 --epochs 1 --lr 0.01 -j 0 .
```
