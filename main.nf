#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LAST_LASTDB                    } from './modules/nf-core/software/last/lastdb/main.nf'   addParams( options: ['args': "-Q0 -u${params.seeding_scheme}"] )
include { LAST_TRAIN                     } from './modules/nf-core/software/last/train/main.nf'    addParams( options: ['args':"--revsym ${params.lastal_args}"] )
include { LAST_LASTAL                    } from './modules/nf-core/software/last/lastal/main.nf'   addParams( options: ['args':"${params.lastal_args}", 'suffix':'.01.original_alignment'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_1 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['suffix':'.02.plot'] )
include { LAST_SPLIT   as LAST_SPLIT_1   } from './modules/nf-core/software/last/split/main.nf'    addParams( options: ['args':'-fMAF+', 'suffix':'.03.split'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_3 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['suffix':'.04.plot'] )
include { LAST_SPLIT   as LAST_SPLIT_2   } from './modules/nf-core/software/last/split/main.nf'    addParams( options: ['args': '--reverse -m1e-5', 'suffix':'.05.split'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_2 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['suffix':'.06.plot'] )
include { LAST_POSTMASK                  } from './modules/nf-core/software/last/postmask/main.nf' addParams( options: ['suffix':'.07.postmasked'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_4 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['suffix':'.08.plot'] )

workflow {
// Turn the file name in a tuple that is appropriate input for LAST_LASTDB
channel
    .value( params.target )
    .map { filename -> file(filename, checkIfExists: true) }
    .map { row -> [ [id:'target'], row] }
    .set { target }

if (params.query) {
    channel
        .from( params.query )
        .map { filename -> file(filename, checkIfExists: true) }
        .map { row -> [ [id:'query'], row] }
        .set { query }
} else {
    // Turn the sample sheet in a channel of tuples suitable for LAST_LASTAL and downstream
    channel
        .fromPath( params.input )
        .splitCsv( header:true, sep:"\t" )
        .map { row -> [ row, file(row.file, checkIfExists: true) ] }
        .set { query }
}

// Index the target genome
    LAST_LASTDB    ( target )
// Optionally train the alignment parameters
    if (params.lastal_params) {
        lastal_query = query.map { row -> [ row[0], row[1], file(params.lastal_params, checkIfExists: true) ] }
    } else {
        LAST_TRAIN ( query,
                     LAST_LASTDB.out.index.map { row -> row[1] } )
        lastal_query = query.join(LAST_TRAIN.out.param_file)
    }
// Align the gennome
    LAST_LASTAL    ( lastal_query,
                     LAST_LASTDB.out.index.map { row -> row[1] } )
// Post-process and plot
    if (! params.skip_dotplot_1 ) {
        LAST_DOTPLOT_1 ( LAST_LASTAL.out.maf,    'png' )
    }
    LAST_SPLIT_1   ( LAST_LASTAL.out.maf )
    if (! params.skip_dotplot_2 ) {
        LAST_DOTPLOT_2 ( LAST_SPLIT_1.out.maf,   'png' )
    }
    LAST_SPLIT_2   ( LAST_SPLIT_1.out.maf )
    if (! params.skip_dotplot_3 ) {
        LAST_DOTPLOT_3 ( LAST_SPLIT_2.out.maf,  'png' )
    }
    LAST_POSTMASK  ( LAST_SPLIT_2.out.maf )
    LAST_DOTPLOT_4 ( LAST_POSTMASK.out.maf, 'png' )
}
