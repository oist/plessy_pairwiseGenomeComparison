#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LAST_LASTDB as LAST_LASTDB_R01 } from './modules/nf-core/software/last/lastdb/main.nf'   addParams( options: ['args': "-Q0 -u${params.seeding_scheme} -R01"] )
include { LAST_TRAIN                     } from './modules/nf-core/software/last/train/main.nf'    addParams( options: ['args':"--revsym ${params.lastal_args}"] )
include { LAST_LASTAL                    } from './modules/nf-core/software/last/lastal/main.nf'   addParams( options: ['args':"--split ${params.lastal_args}"] )
include { LAST_POSTMASK                  } from './modules/nf-core/software/last/postmask/main.nf' addParams( options: ['suffix':'.postmasked'] )
include { filter_mapped_reads as FILTER_READS } from './modules/local/software/filter_mapped_reads/main.nf' addParams( options: [ : ] )

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
    LAST_POSTMASK   ( LAST_LASTAL.out.maf )
if (params.filter_reads) {
    FILTER_READS(query.join(LAST_POSTMASK.out.maf))
}
}
