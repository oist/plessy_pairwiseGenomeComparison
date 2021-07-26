# Pairwise Genome Alignment

## Outputs

For each _query_ genome, this pipeline will align it to the _target_
genome, post-process the alignments and produce dot plots visualisations
at different steps of the workflow.  Each file contains a name suffix
that indicates in which order they were created.

 - `01.original_alignment`
 - `02.plot`
 - `03.split`
 - `04.plot`
 - `05.split`
 - `06.plot`
 - `07.postmasked`
 - `08.plot`

## Mandatory parameters

 * `--target`: path to one genome file in FASTA format.  It will be indexed.

 * `--input`: path to a sample sheet in tab-separated format with one header
   line `id	file`, and one row per genome (ID and path to FASTA file).

   — or —

   `--query`: path to one genome file in FASTA format.

## Options

 * `--with_windowmasker` optionally soft-masks the genome for interspersed
   repeats with lowercase charactesr using the `windowmasker` tool of the
   BLAST suite (https://pubmed.ncbi.nlm.nih.gov/16287941/).  The original
   soft-masking is erased, to match the behaviour of the pipeline when
   this option is not selected.

 * `--seeding_scheme` selects the name of the [LAST seed][]
   The default (`YASS`) searches for “_long-and-weak similarities_” that
   “_allow for mismatches but not gaps_”.  Among alternatives, there
   are (`NEAR`) for “_short-and-strong (near-identical) similarities_
   … _with many gaps (insertions and deletions)_” or `RY32` that
   “_reduces run time and memory use, by only seeking seeds at ~1/32
   of positions in each sequence_”, which is useful when the purpose
   of running this pipeline is only to generate whole-genome dotplots,
   or when sensitivity for tiny fragments may be unnecessary or
   undesirable.

 * `--lastal_args` defaults to `-E0.05 -C2` and is applied to both
   the calls to `last-train` and `lastal`, like in the [LAST cookbook][].

 * `--lastal_params`: path to a file containing alignment parameters
   computed by [`last-train`][] or a [scoring matrix][].  If this option
   is not used, the pipeline will run `last-train` for each query.

  [LAST seed]:      https://gitlab.com/mcfrith/last/-/blob/main/doc/last-seeds.rst
  [LAST cookbook]:  https://gitlab.com/mcfrith/last/-/blob/main/doc/last-cookbook.rst
  [`last-train`]:   https://gitlab.com/mcfrith/last/-/blob/main/doc/last-train.rst
  [scoring matrix]: https://gitlab.com/mcfrith/last/-/blob/main/doc/last-matrices.rst

 * Use `--skip_dotplot_1`, `--skip_dotplot_2`, `--skip_dotplot_3` to
   skip the production of the dot plots that can be computationally expensive
   and visually uninformative on large genomes with shared repeats.
   File suffixes (see above) will not change.

## Fixed arguments (taken from the [LAST cookbook][])

 * The `last-train` commands always runs with `--revsym` as the DNA strands
   play equivalent roles in the studied genomes.

 * The first call to `last-split` runs with `-fMAF+` to make it show per-base
   mismap probabilities.

 * The second call to `last-split` runs with `-m1e-5` to omit alignments with
   mismap probability > 10<sup>−5</sup>.

## Usage

    nextflow run oist/plessy_pairwiseGenomeComparison -r main \
        --input samplesheet.tsv \
        --target sequencefile.fa \
        [-profile yourInstitution]

This pipeline can use the institutional profiles defined in _nf-core_
(<https://github.com/nf-core/configs#documentation>)

## Test

### test remote

    nextflow run oist/plessy_pairwiseGenomeComparison -r main \
        --query https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/genome/genome.fasta \
        --target https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/illumina/fasta/contigs.fasta

### test locally

    nextflow run ./main.nf \
        --input testInput.tsv \
        --target https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/illumina/fasta/contigs.fasta

## Advanced use

### Override computation limits

Computation resources allocated to the processe are set with standard _nf-core_
labels in the [`nextflow.config`](./nextflow.config) file of the pipeline.  To
override their value, create a configuration file in your local directory and
add it to the run's configuration with the `-c` option.

For instance, with file called `overrideLabels.nf` containing the following:

```
process {
  withLabel:process_high {
    time = 3.d
  }
}
```

The command `nextflow -c overrideLabels.nf run …` would set the execution time
limit for the training and alignment (whose module declare the `process_high`
label) to 3 days instead of the 1 hour default.


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
