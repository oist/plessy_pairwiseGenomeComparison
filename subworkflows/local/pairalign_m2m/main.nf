/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { LAST_DOTPLOT as LAST_DOTPLOT_M2O          } from '../../../modules/nf-core/last/dotplot/main'
include { LAST_DOTPLOT as LAST_DOTPLOT_M2M          } from '../../../modules/nf-core/last/dotplot/main'
include { LAST_DOTPLOT as LAST_DOTPLOT_O2O          } from '../../../modules/nf-core/last/dotplot/main'
include { LAST_DOTPLOT as LAST_DOTPLOT_O2M          } from '../../../modules/nf-core/last/dotplot/main'
include { LAST_LASTAL            } from '../../../modules/nf-core/last/lastal/main'
include { LAST_LASTDB            } from '../../../modules/nf-core/last/lastdb/main'
include { LAST_SPLIT as LAST_SPLIT_M2O            } from '../../../modules/nf-core/last/split/main'
include { LAST_SPLIT as LAST_SPLIT_O2O             } from '../../../modules/nf-core/last/split/main'
include { LAST_SPLIT as LAST_SPLIT_O2M             } from '../../../modules/nf-core/last/split/main'
include { LAST_TRAIN             } from '../../../modules/nf-core/last/train/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PAIRALIGN_M2M {

    take:
    ch_target       // channel: target file read in from --target
    ch_queries      // channel: query sequences found in samplesheet read in from --input

    main:

    //
    // MODULE: lastdb
    //
    LAST_LASTDB (
        ch_target
    )

    // MODULE: last-train
    //
    if (params.lastal_params) {
    lastal_query = ch_queries.map { row -> [ row[0], row[1], file(params.lastal_params, checkIfExists: true) ] }
    } else {
    LAST_TRAIN (
        ch_queries,
        LAST_LASTDB.out.index.map { row -> row[1] }  // Remove metadata map
    )
    lastal_query = ch_queries.join(LAST_TRAIN.out.param_file)
    }

    // MODULE: lastal
    //
    LAST_LASTAL (
        lastal_query,
        LAST_LASTDB.out.index.map { row -> row[1] }  // Remove metadata map
    )

    // MODULE: last_dotplot_m2m
    //
    if (! (params.skip_dotplot_m2m) ) {
    LAST_DOTPLOT_M2M (
        LAST_LASTAL.out.maf,
        'png'
    )
    }

    // MODULE: last_split_o2m
    // with_arg
    //
    LAST_SPLIT_O2M (
        LAST_LASTAL.out.maf
    )

    // MODULE: last_dotplot_o2m
    // with_arg
    //
    if (! (params.skip_dotplot_o2m) ) {
    LAST_DOTPLOT_O2M (
        LAST_SPLIT_O2M.out.maf,
        'png'
    )
    }

    // MODULE: last_split_m2o
    //
    LAST_SPLIT_M2O (
        LAST_LASTAL.out.maf
    )

    // MODULE: last_dotplot_m2o
    //
    if (! (params.skip_dotplot_m2o) ) {
    LAST_DOTPLOT_M2O (
        LAST_SPLIT_M2O.out.maf,
        'png'
    )
    }

    // MODULE: last_split_o2o
    // with_arg
    //
    LAST_SPLIT_O2O (
        LAST_SPLIT_M2O.out.maf
    )

    // MODULE: last_dotplot_o2o
    //
    if (! (params.skip_dotplot_o2o) ) {
    LAST_DOTPLOT_O2O (
        LAST_SPLIT_O2O.out.maf,
        'png'
    )
    }

    emit:

    m2m = LAST_LASTAL.out.maf
    m2o = LAST_SPLIT_M2O.out.maf
    o2m = LAST_SPLIT_O2M.out.maf
    o2o = LAST_SPLIT_O2O.out.maf
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
