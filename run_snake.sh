#!/usr/bin/env bash
source /software/conda/3/etc/profile.d/conda.sh
umask 000 # give rights to overwrite clusterLogs after each run
module load Snakemake/7.32.4

snakemake  --cores 24 -s deepconsensus.smk m64093_230202_092756.subreads_deepconsensus.fastq --rerun-incomplete --use-envmodules --jobscript jobscript.sh -p --use-conda --conda-frontend mamba -j 100 --cluster-config deepconsensus_jobsizes_hpc.json --cluster "qsub -A {cluster.account} -q default -l select={cluster.nodes}:ncpus={cluster.ncpus}:arch={cluster.arch}:mem={cluster.mem}:ngpus={cluster.ngpus} -l walltime={cluster.time} -r y -o {cluster.output} -e {cluster.error}" --cluster-status "python snakemake-utils/statuscommand.py"
