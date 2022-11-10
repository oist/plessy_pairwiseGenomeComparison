#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LAST_LASTDB as LAST_LASTDB_R01 } from './modules/nf-core/software/last/lastdb/main.nf'   addParams( options: ['args': "-Q0 -u${params.seeding_scheme} -R01"] )
include { LAST_TRAIN                     } from './modules/nf-core/software/last/train/main.nf'    addParams( options: ['args':"--revsym ${params.lastal_args}"] )
include { LAST_LASTAL                    } from './modules/nf-core/software/last/lastal/main.nf'   addParams( options: ['args':"${params.lastal_args}", 'suffix':'.01.original_alignment'] )
include { LAST_SPLIT   as LAST_SPLIT_1   } from './modules/nf-core/software/last/split/main.nf'    addParams( options: ['args':'-fMAF+', 'suffix':'.02.split'] )
include { LAST_POSTMASK                  } from './modules/nf-core/software/last/postmask/main.nf' addParams( options: ['suffix':'.03.postmasked'] )

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

    LAST_LASTDB_R01 ( target )
    index = LAST_LASTDB_R01.out.index.map { row -> row[1] }
    LAST_TRAIN      ( query,
                      index )
    lastal_query = query.join(LAST_TRAIN.out.param_file)
    LAST_LASTAL     ( lastal_query,
                      index )
    LAST_SPLIT_1    ( LAST_LASTAL.out.maf )
    LAST_POSTMASK   ( LAST_SPLIT_1.out.maf )
}
