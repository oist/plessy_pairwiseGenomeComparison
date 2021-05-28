#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LAST_LASTDB } from './modules/nf-core/software/last/lastdb/main.nf' addParams( options: ['args': '-Q0'] )
include { LAST_TRAIN  } from './modules/nf-core/software/last/train/main.nf'  addParams( options: [:] )
include { LAST_LASTAL } from './modules/nf-core/software/last/lastal/main.nf' addParams( options: [:] )

workflow {

    target = [ [ id:'target' ],
               file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true)
             ]

    query =  [ [ id:'query' ],
               file(params.test_data['sarscov2']['illumina']['contigs_fasta'], checkIfExists: true) ]

    LAST_LASTDB ( target )
    justIndex = LAST_LASTDB.out.index.map { row -> row[1] }
    LAST_TRAIN  ( query, justIndex )
    justParams = LAST_TRAIN.out.param_file.map { row -> row[1] }
    LAST_LASTAL ( query, justIndex, justParams )
}
