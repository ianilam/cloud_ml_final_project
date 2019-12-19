	#!/bin/bash
  
  singularity exec --cleanenv /beegfs/work/public/singularity/sysbench-1.10.1.sif sysbench fileio run --file-test-mode=seqwr > seqwr_log
	singularity exec --cleanenv /beegfs/work/public/singularity/sysbench-1.10.1.sif sysbench fileio run --file-test-mode=seqrewr > seqrewr_log
	singularity exec --cleanenv /beegfs/work/public/singularity/sysbench-1.10.1.sif sysbench fileio run --file-test-mode=seqrd > seqrd_log
	singularity exec --cleanenv /beegfs/work/public/singularity/sysbench-1.10.1.sif sysbench fileio run --file-test-mode=rndrd > rndrd_log
	singularity exec --cleanenv /beegfs/work/public/singularity/sysbench-1.10.1.sif sysbench fileio run --file-test-mode=rndwr > rndwr_log
	singularity exec --cleanenv /beegfs/work/public/singularity/sysbench-1.10.1.sif sysbench fileio run --file-test-mode=rndrw > rndrw_log
	singularity exec --cleanenv /beegfs/work/public/singularity/sysbench-1.10.1.sif sysbench cpu run > cpu_log
	singularity exec --cleanenv /beegfs/work/public/singularity/sysbench-1.10.1.sif sysbench memory run > memory_log
	singularity exec --cleanenv /beegfs/work/public/singularity/sysbench-1.10.1.sif sysbench threads run > threads_log
	singularity exec --cleanenv /beegfs/work/public/singularity/sysbench-1.10.1.sif sysbench mutex run > mutex_log
