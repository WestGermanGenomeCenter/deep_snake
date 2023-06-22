#!/bin/bash
# properties = {properties}
module load Snakemake/6.4.0
module load Miniconda/3_snakemake
source /software/conda/3/etc/profile.d/conda.sh
conda activate test_2
umask 000
{exec_job} 
