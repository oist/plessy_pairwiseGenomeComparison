# Pairwise Genome Alignment

## test remote

    nextflow run oist/plessy_pairwiseGenomeComparison -r main -profile oist --input testInput.tsv --target https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/illumina/fasta/contigs.fasta

## test locally

    nextflow run ./main.nf -profile oist --input testInput.tsv --target https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/illumina/fasta/contigs.fasta

## Semantic versioning

I will apply [semantic versioning](https://semver.org/) to this pipeline:

 - Major increment when the interface changes in a way that is
   backwards-incompatible, in the sense that a run with the same command and
   the same data would produce a different result (except for non-deterministic
   computations).

 - Minor increment for any other change of the interface, such as additions of
   new functionalities.

 - Patch increment for changes that do not modify the interface (bug fixes,
   minor software and module updates, documentation changes, etc.)
