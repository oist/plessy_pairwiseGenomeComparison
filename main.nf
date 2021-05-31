#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LAST_LASTDB                    } from './modules/nf-core/software/last/lastdb/main.nf'   addParams( options: ['args': '-Q0'] )
include { LAST_TRAIN                     } from './modules/nf-core/software/last/train/main.nf'    addParams( options: [:] )
include { LAST_LASTAL                    } from './modules/nf-core/software/last/lastal/main.nf'   addParams( options: ['suffix':'.01.original_alignment'] )
include { LAST_POSTMASK                  } from './modules/nf-core/software/last/postmask/main.nf' addParams( options: ['suffix':'.02.postmasked'] )
include { LAST_SPLIT   as LAST_SPLIT_1   } from './modules/nf-core/software/last/split/main.nf'    addParams( options: ['suffix':'.03.split'] )
include { LAST_MAFSWAP as LAST_MAFSWAP_1 } from './modules/nf-core/software/last/mafswap/main.nf'  addParams( options: ['suffix':'.04.swap'] )
include { LAST_SPLIT   as LAST_SPLIT_2   } from './modules/nf-core/software/last/split/main.nf'    addParams( options: ['suffix':'.05.split'] )
include { LAST_MAFSWAP as LAST_MAFSWAP_2 } from './modules/nf-core/software/last/mafswap/main.nf'  addParams( options: ['suffix':'.06.swap'] )

workflow {
    target = [ [ id:'target' ],
               file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true)
             ]

    query =  [ [ id:'query' ],
               file(params.test_data['sarscov2']['illumina']['contigs_fasta'], checkIfExists: true) ]

    LAST_LASTDB   ( target )
    LAST_TRAIN    ( query,
                    LAST_LASTDB.out.index.map { row -> row[1] } )
    LAST_LASTAL   ( query,
                    LAST_LASTDB.out.index.map { row -> row[1] },
                    LAST_TRAIN.out.param_file.map { row -> row[1] } )
    LAST_POSTMASK ( LAST_LASTAL.out.maf )
    LAST_SPLIT_1    ( LAST_POSTMASK.out.maf )
    LAST_MAFSWAP_1  ( LAST_SPLIT_1.out.maf )
    LAST_SPLIT_2    ( LAST_MAFSWAP_1.out.maf )
    LAST_MAFSWAP_2  ( LAST_SPLIT_2.out.maf )
}
