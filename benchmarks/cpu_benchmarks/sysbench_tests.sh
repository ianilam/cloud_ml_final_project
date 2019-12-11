#!/bin/bash
sysbench fileio run --file-test-mode=seqwr
sysbench fileio run --file-test-mode=seqrewr
sysbench fileio run --file-test-mode=seqrd
sysbench fileio run --file-test-mode=rndrd
sysbench fileio run --file-test-mode=rndwr
sysbench fileio run --file-test-mode=rndrw
sysbench cpu run
sysbench memory run
sysbench threads run
sysbench mutex run
