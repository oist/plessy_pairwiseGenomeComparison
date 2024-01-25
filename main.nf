#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

last_split_args = "${params.last_split_args} -m${params.last_split_mismap}"

if (params.m2m) {
    lastal_args = "${params.lastal_args} ${params.lastal_extra_args}"
    lastal_suffix = '.01.original_alignment'
    train_args = '--revsym'
    readAlignMode = false
} else if (params.read_align) {
    lastal_args = "${params.lastal_args} ${params.lastal_extra_args} --split-m=${params.last_split_mismap}"
    lastal_suffix = '.03.split'
    readAlignMode = true
    train_args = (params.read_align == true) ? '-Q0' : "-Q${params.read_align}"
} else {
    lastal_args = "${params.lastal_args} ${params.lastal_extra_args} --split-m=${params.last_split_mismap} --split-f=MAF+"
    lastal_suffix = '.03.split'
    train_args = '--revsym'
    readAlignMode = false
}

include { BLAST_WINDOWMASKER             } from './modules/nf-core/software/blast/windowmasker/main.nf' addParams( option: [:] )
include { LAST_LASTDB as LAST_LASTDB_R01 } from './modules/nf-core/software/last/lastdb/main.nf'   addParams( options: ['args': "-Q0 -u${params.seed} -c -R01 -S2"] )
include { LAST_LASTDB as LAST_LASTDB_R11 } from './modules/nf-core/software/last/lastdb/main.nf'   addParams( options: ['args': "-Q0 -u${params.seed} -c -R11 -S2"] )
include { LAST_TRAIN                     } from './modules/nf-core/software/last/train/main.nf'    addParams( options: ['args': "${train_args} ${params.lastal_args}", 'suffix':'.00'])
include { LAST_LASTAL                    } from './modules/nf-core/software/last/lastal/main.nf'   addParams( options: ['args':lastal_args, 'suffix':lastal_suffix] )
include { LAST_DOTPLOT as LAST_DOTPLOT_1 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['args':"--rot2=h --sort2=3 --strands2=1 ${params.dotplot_options}", 'suffix':'.02.plot'] )
include { LAST_SPLIT   as LAST_SPLIT_1   } from './modules/nf-core/software/last/split/main.nf'    addParams( options: ['args':"-fMAF+ ${last_split_args}", 'suffix':'.03.split'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_2 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['args':"--rot2=h --sort2=3 --strands2=1 ${params.dotplot_options}", 'suffix':'.04.plot'] )
include { LAST_SPLIT   as LAST_SPLIT_2   } from './modules/nf-core/software/last/split/main.nf'    addParams( options: ['args':"--reverse ${last_split_args}", 'suffix':'.05.split'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_3 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['args':"--rot2=h --sort2=3 --strands2=1 ${params.dotplot_options}", 'suffix':'.06.plot'] )
include { LAST_POSTMASK                  } from './modules/nf-core/software/last/postmask/main.nf' addParams( options: ['suffix':'.07.postmasked'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_4 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['args':"--rot2=h --sort2=3 --strands2=1 ${params.dotplot_options}", 'suffix':'.08.plot'] )

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

if (params.targetName) {
    target = target.map { row -> [ [id: params.targetName]                     , row.tail() ] }
    query  = query.map  { row -> [ [id: params.targetName + '___' + row[0].id] , row.tail() ] }
}

// Optionally mask the genome
    if (params.with_windowmasker) {
        BLAST_WINDOWMASKER ( target )
        target = BLAST_WINDOWMASKER.out.fasta
    }
// Index the target genome
    if (params.with_windowmasker) {
        LAST_LASTDB_R11    ( target )
        index = LAST_LASTDB_R11.out.index.map { row -> row[1] }
    } else {
        LAST_LASTDB_R01    ( target )
        index = LAST_LASTDB_R01.out.index.map { row -> row[1] }
    }
// Optionally train the alignment parameters
    if (params.lastal_params) {
        lastal_query = query.map { row -> [ row[0], row[1], file(params.lastal_params, checkIfExists: true) ] }
    } else {
        LAST_TRAIN ( query,
                     index )
        lastal_query = query.join(LAST_TRAIN.out.param_file)
    }
// Align the genomes
    LAST_LASTAL    ( lastal_query,
                     index )
// If --m2m the result is a many-to-many alignment and we need last-split
// to compute the many-to-one alignment.
    if (params.m2m) {
        if (! params.skip_dotplot_1 ) {
            LAST_DOTPLOT_1 ( LAST_LASTAL.out.maf, 'png' )
        }
        LAST_SPLIT_1   ( LAST_LASTAL.out.maf )
        many_to_one_aln = LAST_SPLIT_1.out.maf
    } else {
// Otherwise the output of lastal is a already a many_to_one alignment.
        many_to_one_aln = LAST_LASTAL.out.maf
    }
// Skip the last steps if we are aligning reads
    if (! readAlignMode) {
        if (! params.skip_dotplot_2 ) {
        LAST_DOTPLOT_2 ( many_to_one_aln, 'png' )
        }
        LAST_SPLIT_2   ( many_to_one_aln )
        if (! params.skip_dotplot_3 ) {
        LAST_DOTPLOT_3 ( LAST_SPLIT_2.out.maf,  'png' )
        }
// Optional postmask step
        if (params.postmask) {
            LAST_POSTMASK  ( LAST_SPLIT_2.out.maf )
            LAST_DOTPLOT_4 ( LAST_POSTMASK.out.maf, 'png' )
        }
    }
}
