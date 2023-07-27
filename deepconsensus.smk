# smk deepconsensus
# --cluster "qsub -m n -A {cluster.account} ${QUEUE} -l select={cluster.nodes}:ncpus={config["bcl2fastq"]["threads"]}:mem={cluster.mem} -l walltime={cluster.time} -r n -o {cluster.output} -e {cluster.error}"
# imports
from snakemake.utils import min_version
import os
import sys
import pandas as pd

# Snakemake configs and setup
min_version("6.4.0")

configfile: "config.yaml"
outputfolder = config["Outputfolder"]
 ###

chunkN = config['split_into_n_chunks']



sample_names = list(range(1,chunkN+1))

def get_chunknames():
    all_chunknames = list ()
    all_chunknames.extend(expand("{sample}/{nchunks_total}",nchunks_total = chunkN,sample = sample_names))
    return all_chunknames [:chunkN]

def get_of_chunks():
    all_chunks = list ()
    all_chunks.extend(expand("{sample}-of-{nchunks_total}",nchunks_total = chunkN,sample = sample_names))
    return all_chunks [:chunkN]



wildcard_constraints:
# restricting the input filename list: not use -of- in any subreads file to avoid circlesnake
    name= "m.*"

rule all:
    input:
        final_fastq = "{name}_deepconsensus.fastq"


rule index_subreads:
    input:
        input_subreads_bam = "{name}.bam"
    output:
        subread_pbindex = "{name}.bam.pbi"
    conda:
        "deepconsensus_software_env.yml"
    wildcard_constraints:
        name = "m\d+_\d+_\d+\.subreads"
    shell:
        """
        pbindex {input}

        """

rule ccs_lowq: 
    input:
        input_subreads_bam = "{name}.bam",
        subread_pbindex = "{name}.bam.pbi"

    params:
        min_qual = config["ccs_lowq_filter"],
        n_threads = config["ccs_lowq_num_threads"],
        test2 = str(''.join(expand("{{shard_of}}"))).replace('-of-','/'),
    wildcard_constraints:
        #name = "m\d+_\d+_\d+\.subreads",
        #shard_of = "-of-{1,1}"
    output: 
        output_files = expand("{{name}}_{{shard_of}}_ccs_lq.bam")
    conda:
        "deepconsensus_software_env.yml"
    shell:
        """
        ccs {input.input_subreads_bam} --min-rq={params.min_qual} -j {params.n_threads} --chunk=`echo {params.test2} | sed 's/-of-/\//'` {output.output_files}
        """

rule map_lowq_to_subreads:
#
    input:
        ccs_lq = expand("{{name}}_{{shard_of}}_ccs_lq.bam"),
        input_subreads_bam = "{name}.bam"
    params:
        n_threads = config["ccs_lowq_num_threads"]
    output:
        mapped_bam = expand("{{name}}_{{shard_of}}_ccs_lq_mapped_to_subreads.bam")

    conda:
        "deepconsensus_software_env.yml"
    shell:
        """
        actc -j {params.n_threads} {input.input_subreads_bam} {input.ccs_lq} {output} --log-level DEBUG
        """

rule run_deep:
    input:
        mapped_bam = expand("{{name}}_{{shard_of}}_ccs_lq_mapped_to_subreads.bam"),
        ccs_lq = expand("{{name}}_{{shard_of}}_ccs_lq.bam")
    params:
        checkpoint_file = config["checkpoint_file"],
        mapped_bam = expand("{{name}}_{{shard_of}}_ccs_lq_mapped_to_subreads.bam"),
        ccs_lq = expand("{{name}}_{{shard_of}}_ccs_lq.bam"),
        logfile = expand("{{name}}_{{shard_of}}_deepconsensus_logfile.log")
    threads:
        config["ccs_lowq_num_threads"]      

    output:
        deep_chunk = expand("{{name}}_{{shard_of}}_deepconsensus.fastq"),
        #deep_chunk = expand("{{name}}_{{shard_of}}_deepconsensus.fastq"),
    conda:
        "deepconsensus_software_env.yml"
    shell:
       """
       module load DeepConsensus &>{params.logfile}
       nice deepconsensus run --subreads_to_ccs={params.mapped_bam} --ccs_bam={params.ccs_lq} --checkpoint={params.checkpoint_file} --output={output} --batch_zmws 1000 --cpus={threads} &>{params.logfile}
       """

rule cat_fastqs:
    input:
        deep_chunk = expand("{{name}}_{shard_of}_deepconsensus.fastq",shard_of =  get_of_chunks()),
    output:
        final_fastq = "{name}_deepconsensus.fastq"
    wildcard_constraints:
        shard_of = "-of-{1,1}" ,
        name = "m\d+_\d+_\d+\.subreads"
    shell:
        """
        cat {input} >> {output}
        """
        
rule demux:
    input:
        fastq_w_barc = "{name}_deepconsensus.fastq"
    params:
        barcode_file = config["barcode_file"]
    output:
        demuxed_fastq = "{name}_deepconsensus_demultiplexed.fastq"
    conda:
        "deepconsensus_software_env.yml"
    shell:
        """
        lima {input} {params.barcode_file} {output}
        """
