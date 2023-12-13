# Pairwise Genome Alignment

## If you use this pipeline, please cite:

_Extreme genome scrambling in cryptic Oikopleura dioica species_. Charles Plessy, Michael J. Mansfield, Aleksandra Bliznina, Aki Masunaga, Charlotte West, Yongkai Tan, Andrew W. Liu, Jan Grašič, María Sara del Río Pisula, Gaspar Sánchez-Serna, Marc Fabrega-Torrus, Alfonso Ferrández-Roldán, Vittoria Roncalli, Pavla Navratilova, Eric M. Thompson, Takeshi Onuma, Hiroki Nishida, Cristian Cañestro, Nicholas M. Luscombe. bioRxiv 2023.05.09.539028; doi: https://doi.org/10.1101/2023.05.09.539028

And also please cite the [LAST papers](https://gitlab.com/mcfrith/last/-/blob/main/doc/last-papers.rst).

## Outputs

For each _query_ genome, this pipeline will align it to the _target_
genome, post-process the alignments and produce dot plots visualisations
at different steps of the workflow.  Each file contains a name suffix
that indicates in which order they were created.

 - `00.par` is the alignment parameters computed by `last-train` (optional)
 - `01.original_alignment` is the _**many-to-many**_ alignment between _target_ and _query_ genomes. (optional)
 - `02.plot` (optional)
 - `03.split` is the _**many-to-one**_ alignment regions of the _target_ genome are matched at most once by the _query_ genome.
 - `04.plot` (optional)
 - `05.split` is the _**one-to-one**_ alignment between the _target_ and _query_ genomes.
 - `06.plot` (optional)
 - `07.postmasked` is a filtered _**one-to-one**_ alignment where low-confidence matches made mostly of masked regions are removed. (optional)
 - `08.plot` (optional)

## Mandatory parameters

 * `--target`: path or URL to one genome file in FASTA format.  It will be indexed.

 * `--input`: path to a sample sheet in tab-separated format with one header
   line `id	file`, and one row per genome (ID and path or URL to FASTA file).

   — or —

   `--query`: path or URL to one genome file in FASTA format.

## Options

 * `--with_windowmasker` optionally soft-masks the genome for interspersed
   repeats with lowercase charactesr using the `windowmasker` tool of the
   BLAST suite (https://pubmed.ncbi.nlm.nih.gov/16287941/).  The original
   soft-masking is erased, to match the behaviour of the pipeline when
   this option is not selected.

 * `--seeding_scheme` selects the name of the [LAST seed][]
   The default (`YASS`) searches for “_long-and-weak similarities_” that
   “_allow for mismatches but not gaps_”.  Among alternatives, there
   are `NEAR` for “_short-and-strong (near-identical) similarities_
   … _with many gaps (insertions and deletions)_”, `MAM8` to find _“weak
   similarities with high sensitivity, but low speed and high memory usage”_
   or `RY64` that “_reduces run time and memory use, by only seeking seeds at
   ~1/64 of positions in each sequence_”, which is useful when the purpose of
   running this pipeline is only to generate whole-genome dotplots, or when
   sensitivity for tiny fragments may be unnecessary or undesirable.

 * `--lastal_args` defaults to `-D1e9 -C2` and is applied to both
   the calls to `last-train` and `lastal`, like in the [LAST cookbook][]
   and the [last-genome-alignments][] tutorial.

 * `--lastal_extr_args` is only passed to `lastal` and should be used for
   arguments that are not recognised by `last-train`.

 * `--lastal_params`: path to a file containing alignment parameters
   computed by [`last-train`][] or a [scoring matrix][].  If this option
   is not used, the pipeline will run `last-train` for each query.

 * `--skip_m2m`: (default: true) Skip the many-to-many alignment.  This saves
   time and a considerable amount of space.  Implies `--skip_dotplot_1`.

 * `--one_to_one_only`: do not save the results of the `lastal` step.  With
   `--skip_m2m` `true` (default), the only alignment file will be the
   _one-to-one_ output of `last-split`, thus saving disk space.

 * By default, `last-split` runs with `-m1e-5` to omit alignments with
   mismap probability > 10<sup>−5</sup>, but this can be overriden with
   the `--last_split_mismap` option.

 * `--last_split_args` defaults to empty value and is not very useful at the
   moment, but is kept for backwards compatibility.  It can be used to pass
   options to `last-split`.  Note that if you used `--skip_m2m`, the split
   parameters have to be passed in `--lastal_extra_args` and have different
   names (see _split options_ in the [lastal documentation][]).

 * The dotplots can be modified by overriding defaults and passing new
   arguments via the `--dotplot_options` argument.  Defaults and available
   options can be seen on the manual page of the [`last-dotplot`][] program.
   By default in this pipeline, the sequences of the _query_ genome are
   sorted and oriented by their alignment to the _target_ genome
   (`--sort2=3 --strands2=1`). For readability, their names are written
   horizontally (`--rot2=h`).

 * Use `--skip_dotplot_1`, `--skip_dotplot_2`, `--skip_dotplot_3` to
   skip the production of the dot plots that can be computationally expensive
   and visually uninformative on large genomes with shared repeats.
   File suffixes (see above) will not change.

 * By default the LAST index is named `target` and the ouput files are named
   from the query IDs.  Use the `--targetName` option to provide a name
   that will be used for the LAST index and that will be prefixed to the
   query IDs with a `___` separator.

 * Use `--postmask` to filter out the one-to-one alignments that contain a
   significant fraction of soft-masked (lowercased) sequences, using the
   [`last-postmask`][] tool.  This is not necessary if `lastdb` was run with the
  `-c` option, which is the default since version `7.0.0`.

  [`lastal`]:       https://gitlab.com/mcfrith/last/-/blob/main/doc/lastal.rst
  [`last-dotplot`]: https://gitlab.com/mcfrith/last/-/blob/main/doc/last-dotplot.rst
  [`last-postmask`]:https://gitlab.com/mcfrith/last/-/blob/main/doc/last-postmask.rst
  [LAST seed]:      https://gitlab.com/mcfrith/last/-/blob/main/doc/last-seeds.rst
  [LAST cookbook]:  https://gitlab.com/mcfrith/last/-/blob/main/doc/last-cookbook.rst
  [`last-train`]:   https://gitlab.com/mcfrith/last/-/blob/main/doc/last-train.rst
  [LAST tuning]:    https://gitlab.com/mcfrith/last/-/blob/main/doc/last-tuning.rst
  [scoring matrix]: https://gitlab.com/mcfrith/last/-/blob/main/doc/last-matrices.rst
  [lastal documentation]: https://gitlab.com/mcfrith/last/-/blob/main/doc/lastal.rst
  [last-genome-alignments]: https://github.com/mcfrith/last-genome-alignments

## Fixed arguments (taken from the [LAST cookbook][] and the [LAST tuning][] manual)

 * The `lastdb` step soft-masks simple repeats by default, (`-c -R01`).
   It indexes both strands (`-S2`), which increases speed at the expense
   of memory usage.

 * The `last-train` commands runs with `--revsym` as the DNA strands
   play equivalent roles in the studied genomes, unless the `--read_align`
   option is selected.

 * `last-split` runs with `-fMAF+` to make it show per-base mismap
   probabilities, except in read alignment mode (see below).

## Read alignment mode

The `--read_align` option can be used to align sequencing reads to a genome.
The output will be a single alignment file with a many-to-one relationship
between the _target_ genome and the _query_ reads.  The alignment process is
similar with the `--skip_m2m` mode, with the difference that the scoring matrix
computed by [`last-train`][] is allowed to be asymmetric.  FASTA and FASTQ
formats are allowed, and by default the quality values are ignored.  This can
be changed by passing `keep`, `sanger`, `solexa`, or `illumina` as an argument
to `--read_align` as described in the [`lastal`][] documentation.  The default
seeding scheme is used but it may be a good idea to use `RY32` instead to speed
up the alignment. 

## Usage

    nextflow run oist/plessy_pairwiseGenomeComparison -r main \
        --input samplesheet.tsv \
        --target sequencefile.fa \
        [-profile yourInstitution]

This pipeline can use the institutional profiles defined in _nf-core_
(<https://github.com/nf-core/configs#documentation>)

## Test

Note that your tests may fail if you do not set the `-profile` option to a
configuration suitable for your system.  See <https://nf-co.re/configs> for
common ones.  You also need to ensure that your work directory is writable by
your compute nodes, by setting the `-work-dir` option appropriately.

### test remote

    nextflow run oist/plessy_pairwiseGenomeComparison -r main \
        --target https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/genome/genome.fasta \
        --query https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/illumina/fasta/contigs.fasta

### test locally

    nextflow run ./main.nf \
        --input testInput.tsv \
        --target https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/genome/genome.fasta

### test read alignment mode (remote)

    nextflow run oist/plessy_pairwiseGenomeComparison -r main \
        --target https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/genome/genome.fasta \
        --query https://github.com/nf-core/test-datasets/raw/modules/data/genomics/sarscov2/nanopore/fastq/test_2.fastq.gz \
        --read_align

## Advanced use

### Reports

The results directory contains three reports generated by Nextflow:

 - `report.html` informs on the pipeline, its version, some metrics about
   execution time.
 - `timeline.html` displays the execution times like a Gantt chart.
 - `trace.tsv` provides the raw data and can be displayed with the
   `column -ts$'\t'` command.

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

I apply [semantic versioning](https://semver.org/) to this pipeline:

 - Major increment when the interface changes in a way that is
   backwards-incompatible, in the sense that a run with the same command and
   the same data would produce a different result (except for non-deterministic
   computations).

 - Minor increment for any other change of the interface, such as additions of
   new functionalities.

 - Patch increment for changes that do not modify the interface (bug fixes,
   minor software and module updates, documentation changes, etc.)
