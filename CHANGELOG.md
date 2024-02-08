## Upcoming changes for version 8.0.0

 - Use default `-D` value (total input length) for `last-train`.  Keep
   `-D1e9` for `lastal`.

 - Upgrade LAST to version 1541.  This introduces seed-specific defaults
   for the maximum repeat unit length when the _target_ genome is
   soft-masked by `lastdb`.

 - Rename the `--seeding_scheme` option to just `--seed`, which is shorter
   and easier to remember.

 - Rename the `--skip_m2m` (default `true`) option to just `--m2m` (default
   `false`).

 - Rename the files and options to clearly indicate `m2m`, `m2o` and `o2o`.

## 7.1.0

 - Output a text-formatted trace file to profile resource usage.

 - Reduce the number of CPUs of `last-split` tasks to 2.

 - Update to LAST 1522 to allow for `RY128` seeds.

## 7.0.0

 - `--skip_m2m` now defaults to `true`.

 - Add a `--one_to_one_only` option to prevent copying the `lastal` alignment
   to the results folder, thus saving disk space.

 - Add a `--lastal_extra_args` option to pass `lastal` arguments that
   are not recognised by `last-train`.

 - Change the suffix of the parameter file from `par` to `00.par` for better
   sorting of the file names.

 - Stop providing a copy of the LAST index in the results folder.

 - Index both strands to speed up computation (at the expense of memory usage).

 - Add a `--last_split_mismap` option and revert the default to `1e-5`. 

 - Update LAST to version 1519 and `windowmasker` to version 2.15.0.

 - Default to soft-mask lowercased letters (option `-c` of `lastdb`), and make
   the postmask step optional.

 - Replace the `-E0.05` option (_“Maximum expected alignments per square
   giga”_)  with `-D1e9` (_“Report alignments that are expected by chance at
   most once per LENGTH query letters”_) to match the tutorials closer.  Both
   options should have similar effects, but `-D` is easier to explain.

## 6.1.0

 - New `--read_align` option to utilise the pipeline for mapping
   _query_ reads to a _target_ genome.

## 6.0.0

 - New `--skip_m2m` to skip the generation of the many-to-many alignment,
   which consumes a large amount of time and disk space.

 - Change default `-m` value of `last-split` to the default (`-m1` at the
   moment) and add a new option `--last_split_args` to allow setting other
   values (such as `-m1e-5` that was used previously).

 - New `--targetName` option to include target genome names in the
   output files.

## 5.2.2

 - Guess index file name by searching for `prj` files and selecting
   the shortest base name.  The previous method failed when the
   indexed genome was large enough to cause the generation of multiple
   `prj` (or `des`) files.  Version `5.2.1` attempted to solve the
   problem but failed.

## 5.2.0

 - New `--dotplot_options` option to modify the dot plots.  New
   default sort and orientation of the _query_ genome (to match
   the alignment to the _target_ genome).  _query_ genome sequence
   names are now written horizontally.

 - In the README's examples, reversed the role of the target and
   query sequences for better demonstrating the new dotplot
   defaults.

## 5.1.0

 - New `--with_windowmasker` option to soft-mask the genome with the
   `windowmasker` tool of the BLAST suite.

## 5.0.0

  - Move _postmask_ step at the end of the workflow, so that `last-split`
    has more information.
  - Use the new `--reverse` option of `last-split` so that the use of
    `maf-swap` (and the files it generates) can be avoided.
  - Pass `fMAF+` to the fist call of `last-split` and `-m1e-5`
    to the second call, as in the upstream cookbook.
  - Update LAST to version 1250.
  - Use `YASS` as default seed and advertise `RY32` in the README.

## 4.2.0

  - New options `--skip_dotplot_1`, `_2`, and `_3` to skip computationally
    expensive and not always so useful plots.

## 4.1.1

  - Correct version number in `nextflow.config` and brush up documentation.

## 4.1.0

 - Optionally pass a single alignment parameter file with a new
   `--lastal_params` option.  Doing so skips `last-train`.
 - Re-implement the correction of 4.0.0 in a way that complies with
   nf-core, using a _join_ operation.

## 4.0.0

 - *Important* bug fix ensuring that the right trained parameter set is used
   with the right genome. (2c05b2de2da69864020fc4203f15d2fa14350d9c)

## 3.1.1

 - Update LAST modules to the version accepted in nf-core.

## 3.1.0

 - New `--query` option that saves the effort of creating a sample sheet
   when there is only one query genome.

## 3.0.0

 - Force the score matrix to be symmetric (pass `--revsym` to `last-train`).
 - Allow passing common arguments to `last-train` and `lastal` with the
   `--lastal_args` option, defaulting to `-E0.05 -C2`.

## 2.0.1

 - Correct a bug that caused index names to not be detected properly
   when seeding schemes such as `MAM8` are used.

## 2.0.0

 - New `--seeding_scheme` that defaults to `NEAR`.  In previous versions the
   `lastdb` command did not receive a parameter and defaulted to `YASS`.

## 1.1.1

 - Solve a channel bug that prevented processing more than one sample.

## 1.1.0

 - Add dotplots.

## 1.0.1

 - Set computation resources for process labels.

## 1.0.0

 - Initial version.
