# deepconsensus 1.2 snakemake pipeline
This snakemake-based workflow takes in a subreads.bam and results in a deepconsensus.fastq
- no methylation calls !

The metadata id of the subreads file needs to be: "m[numeric]_[numeric]_[numeric].subreads.bam"

Chunking (how many subjobs) and ccs min quality filter can be adjusted in the config.yaml

the checkpoint model for deepconsensus1.2 should be accessible like this:
gsutil cp -r gs://brain-genomics-public/research/deepconsensus/models/v1.2/model_checkpoint/* "${QS_DIR}"/model/
if that does not work, try to download all at:
https://console.cloud.google.com/storage/browser/brain-genomics-public/research/deepconsensus/models?pageState=(%22StorageObjectListTable%22:(%22f%22:%22%255B%255D%22))&prefix=&forceOnObjectsSortingFiltering=false

A run example is included in the run_snake.sh

Feedback / pull requests welcome!

Developed by Daniel Rickert @ WGGC Düsseldorf

more to look at:

https://www.youtube.com/watch?v=TlWtIao2i9E

https://www.nature.com/articles/s41587-022-01435-7
