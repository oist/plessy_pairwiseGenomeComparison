#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LAST_LASTDB                    } from './modules/nf-core/software/last/lastdb/main.nf'   addParams( options: ['args': '-Q0'] )
include { LAST_TRAIN                     } from './modules/nf-core/software/last/train/main.nf'    addParams( options: [:] )
include { LAST_LASTAL                    } from './modules/nf-core/software/last/lastal/main.nf'   addParams( options: ['suffix':'.01.original_alignment'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_1 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['suffix':'.02.plot'] )
include { LAST_POSTMASK                  } from './modules/nf-core/software/last/postmask/main.nf' addParams( options: ['suffix':'.03.postmasked'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_2 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['suffix':'.04.plot'] )
include { LAST_SPLIT   as LAST_SPLIT_1   } from './modules/nf-core/software/last/split/main.nf'    addParams( options: ['suffix':'.05.split'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_3 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['suffix':'.06.plot'] )
include { LAST_MAFSWAP as LAST_MAFSWAP_1 } from './modules/nf-core/software/last/mafswap/main.nf'  addParams( options: ['suffix':'.07.swap'] )
include { LAST_SPLIT   as LAST_SPLIT_2   } from './modules/nf-core/software/last/split/main.nf'    addParams( options: ['suffix':'.08.split'] )
include { LAST_MAFSWAP as LAST_MAFSWAP_2 } from './modules/nf-core/software/last/mafswap/main.nf'  addParams( options: ['suffix':'.09.swap'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_4 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['suffix':'.10.plot'] )

workflow {
// Turn the file name in a tuple that is appropriate input for LAST_LASTDB
channel
    .from( params.target )
    .map { filename -> file(filename, checkIfExists: true) }
    .map { row -> [ [id:'target'], row] }
    .set { target }

// Turn the sample sheet in a channel of tuples suitable for LAST_LASTAL and downstream
channel
    .fromPath( params.input )
    .splitCsv( header:true, sep:"\t" )
    .map { row -> [ row, file(row.file, checkIfExists: true) ] }
    .set { query }

// Align the genomes
    LAST_LASTDB    ( target )
    LAST_TRAIN     ( query,
                     LAST_LASTDB.out.index.map { row -> row[1] } )
    LAST_LASTAL    ( query,
                     LAST_LASTDB.out.index.map { row -> row[1] },
                     LAST_TRAIN.out.param_file.map { row -> row[1] } )
    LAST_DOTPLOT_1 ( LAST_LASTAL.out.maf )
    LAST_POSTMASK  ( LAST_LASTAL.out.maf )
    LAST_DOTPLOT_2 ( LAST_POSTMASK.out.maf )
    LAST_SPLIT_1   ( LAST_POSTMASK.out.maf )
    LAST_DOTPLOT_3 ( LAST_SPLIT_1.out.maf )
    LAST_MAFSWAP_1 ( LAST_SPLIT_1.out.maf )
    LAST_SPLIT_2   ( LAST_MAFSWAP_1.out.maf )
    LAST_MAFSWAP_2 ( LAST_SPLIT_2.out.maf )
    LAST_DOTPLOT_4 ( LAST_MAFSWAP_2.out.maf )
}
