#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BLAST_WINDOWMASKER             } from './modules/nf-core/software/blast/windowmaker/main.nf' addParams( option: [:] )
include { LAST_LASTDB as LAST_LASTDB_R01 } from './modules/nf-core/software/last/lastdb/main.nf'   addParams( options: ['args': "-Q0 -u${params.seeding_scheme} -R01"] )
include { LAST_LASTDB as LAST_LASTDB_R11 } from './modules/nf-core/software/last/lastdb/main.nf'   addParams( options: ['args': "-Q0 -u${params.seeding_scheme} -R11"] )
include { LAST_TRAIN                     } from './modules/nf-core/software/last/train/main.nf'    addParams( options: ['args':"--revsym ${params.lastal_args}"] )
include { LAST_LASTAL                    } from './modules/nf-core/software/last/lastal/main.nf'   addParams( options: ['args':"${params.lastal_args}", 'suffix':'.many2many_alignment'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_1 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['args':"--rot2=h --sort2=3 --strands2=1 ${params.dotplot_options}", 'suffix':'.many2many_plot'] )
include { LAST_MAFCONVERT as LAST_MAFCONVERT_1_AXT } from './modules/nf-core/software/last/mafconvert/main.nf'  addParams( options: ['args':"", 'suffix':'.many2many_plot'] )
include { LAST_MAFCONVERT as LAST_MAFCONVERT_1_GFF } from './modules/nf-core/software/last/mafconvert/main.nf'  addParams( options: ['args':"", 'suffix':'.many2many_plot'] )
include { LAST_SPLIT   as LAST_SPLIT_1   } from './modules/nf-core/software/last/split/main.nf'    addParams( options: ['args':'-fMAF+', 'suffix':'.many2one_alignment'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_2 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['args':"--rot2=h --sort2=3 --strands2=1 ${params.dotplot_options}", 'suffix':'.many2one_plot'] )
include { LAST_SPLIT   as LAST_SPLIT_2   } from './modules/nf-core/software/last/split/main.nf'    addParams( options: ['args': '--reverse -m1e-5', 'suffix':'.one2one_alignment'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_3 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['args':"--rot2=h --sort2=3 --strands2=1 ${params.dotplot_options}", 'suffix':'.one2one_plot'] )
include { LAST_MAFCONVERT as LAST_MAFCONVERT_4_ONE2ONE_AXT } from './modules/nf-core/software/last/mafconvert/main.nf' addParams( options: ['args':"", 'suffix':'.one2one_alignment'])
include { LAST_POSTMASK                  } from './modules/nf-core/software/last/postmask/main.nf' addParams( options: ['suffix':'.repetitive_elements_filter'] )
include { LAST_DOTPLOT as LAST_DOTPLOT_4 } from './modules/nf-core/software/last/dotplot/main.nf'  addParams( options: ['args':"--rot2=h --sort2=3 --strands2=1 ${params.dotplot_options}", 'suffix':'.repetitive_elements_filter_plot'] )
include { LAST_MAFCONVERT as LAST_MAFCONVERT_4_AXT } from './modules/nf-core/software/last/mafconvert/main.nf'  addParams( options: ['args':"", 'suffix':'.repetitive_elements_filter'] )
include { LAST_MAFCONVERT as LAST_MAFCONVERT_4_GFF } from './modules/nf-core/software/last/mafconvert/main.nf'  addParams( options: ['args':"-J 1e6", 'suffix':'.repetitive_elements_filter'] )
include { GENOMICBREAKS_STATS} from './modules/local/software/genomicbreaks/stats/main.nf'         addParams( options: [:] )

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

// The GBreaks template channel
channel
    .value( params.GBtempl )
    .map { filename -> file(filename, checkIfExists: true) }
    .set { GBtempl }

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
// Align the gennome
    LAST_LASTAL    ( lastal_query,
                     index )
// Post-process and plot
    if (! params.skip_dotplot_1 ) {
        LAST_DOTPLOT_1 ( LAST_LASTAL.out.maf,    'png' )
	LAST_MAFCONVERT_1_AXT ( LAST_LASTAL.out.maf, 'axt' )
	LAST_MAFCONVERT_1_GFF ( LAST_LASTAL.out.maf, 'gff' )
    }
    LAST_SPLIT_1   ( LAST_LASTAL.out.maf )
    if (! params.skip_dotplot_2 ) {
        LAST_DOTPLOT_2 ( LAST_SPLIT_1.out.maf,   'png' )
    }
    LAST_SPLIT_2   ( LAST_SPLIT_1.out.maf )
    if (! params.skip_dotplot_3 ) {
        LAST_DOTPLOT_3 ( LAST_SPLIT_2.out.maf,  'png' )
	LAST_MAFCONVERT_4_ONE2ONE_AXT ( LAST_SPLIT_2.out.maf, 'axt' )
    }
    LAST_POSTMASK  ( LAST_SPLIT_2.out.maf )
    LAST_DOTPLOT_4 ( LAST_POSTMASK.out.maf, 'png' )
    LAST_MAFCONVERT_4_AXT ( LAST_POSTMASK.out.maf, 'axt' )
    LAST_MAFCONVERT_4_GFF ( LAST_POSTMASK.out.maf, 'gff' )
    if (params.run_GBreaks_analysis) {
      GENOMICBREAKS_STATS ( LAST_MAFCONVERT_4_AXT.out.axt.join(LAST_MAFCONVERT_4_GFF.out.gff), GBtempl )
    }
}
