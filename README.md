# Pairwise Genome Alignment

## Options

 * `--seeding_scheme` selects the name of the [LAST seed](https://gitlab.com/mcfrith/last/-/blob/main/doc/last-seeds.rst)
   The default (`NEAR`) searches for “_short-and-strong (near-identical)
   similarities_ … _with many gaps (insertions and deletions)_”.  Among
   alternatives, there is `YASS` for “_long-and-weak similarities_” that
   “_allow for mismatches but not gaps_”.

 * `--lastal_args` defaults to `-E0.05 -C2` and is applied to both
   the calls to `last-train` and `lastal`, like in the
   [LAST cookbook](https://gitlab.com/mcfrith/last/-/blob/main/doc/last-cookbook.rst).

## Fixed arguments

 * `--revsym` is hardcoded the call to `last-train` as the DNA strands
   play equivalent roles in the studied genomes.

## Test

### test remote

    nextflow run oist/plessy_pairwiseGenomeComparison -r main -profile oist --input testInput.tsv --target https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/illumina/fasta/contigs.fasta

### test locally

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
