# Change log

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
