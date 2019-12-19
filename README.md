# Performance Analysis of Different Containers on AWS Free Tier
Nisarg Thakkar, Yang-Yao Lin, Ian Lam

## Project Overview
In this project, we compare the performance of various container runtimes and isolation tools under CPU benchmarking loads as well as Neural Network workloads. To achieve this, we ran a set of system performance benchmark tools and Machine Learning experiments within Docker, rkt, LXC, and chroot on an AWS Free Tier EC2 instance. We compared the results against ones from the same AWS setup without any container and ones from Bare-Metal on Prince cluster.

## Running Benchmarks on Prince
1. To acquire shared CPU, run following command on Prince:
   
   `srun -p c32_41 -t24:00:00 --cpus-per-task=1 --mem=1GB --pty /bin/bash`
2. To acquire exclusive CPU, run following command on Prince:
   
   `srun -p c32_41 -t24:00:00 --cpus-per-task=1 --exclusive --mem=1GB --pty /bin/bash`
