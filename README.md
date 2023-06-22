# deepconsensus 1.2 snakemake pipeline
This snakemake-based workflow takes in a m....subreads.bam and results in a deepconsensus.fastq
- no kinetics !

The metadata id of the subreads file needs to be: m[numeric]_[numeric]_[numeric].subreads.bam
Chunking (how many subjobs) and ccs min quality filter can be adjusted in the config.yaml
A run example is included in the run_snake.sh

Feedback / pull requests welcome!

Developed by Daniel Rickert @ WGGC Düsseldorf

