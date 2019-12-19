To get the output log file, mount the logs using "docker run -v" as following:  
```bash
cd <benchmark_dir>/  
docker build -t <your_tag> .  
docker run -v <your_log_path>:/logs <your_tag>
```

If you want to try without docker, use:  
```
python3 app/benchmark.py
```
