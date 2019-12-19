To run every benchmark in AWS:

```bash
./setup.sh
```

Since Prince doesn't have sysbench preinstalled, we need to run our tests in a Singularity container. To run the sysbench tests on prince, run the following command:

```bash
./sysbench_prince.sh
```
