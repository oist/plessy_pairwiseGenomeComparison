## 6.0.0

 - Change default `-m` value of `last-split` to the default (`-m1` at the
   moment) and add a new option `--last_split_args` to allow setting other
   values (such as `-m1e-5` that was used previously).

## 5.2.2

 - Guess index file name by searching for `prj` files and selecting
   the shortest base name.  The previous method failed when the
   indexed genome was large enough to cause the generation of multiple
   `prj` (or `des`) files.  Version `5.2.1` attempted to solve the
   problem but failed.
>>>>>>> main

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
