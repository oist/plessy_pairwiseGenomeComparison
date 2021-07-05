// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process TANTAN {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::tantan=26" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/tantan:26--h1b792b2_1"
    } else {
        container "quay.io/biocontainers/tantan:26--h1b792b2_1"
    }

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.fasta"), optional: true, emit: fasta
    tuple val(meta), path("*.txt"),   optional: true, emit: txt
    tuple val(meta), path("*.bed"),   optional: true, emit: bed
    path "*.version.txt"                            , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def ext      = "fasta"
    if (options.args.tokenize().contains("-f1")) ext = "txt"
    if (options.args.tokenize().contains("-f2")) ext = "txt"
    if (options.args.tokenize().contains("-f3")) ext = "bed"
    if (options.args.tokenize().contains("-f4")) ext = "txt"
    if (options.args.tokenize().contains("-f")) error "-f option must not be followed by space in this module so that format can be detected automatically"
    """
    tantan \\
        $fasta \\
        $options.args \\
        > ${prefix}.$ext \\

    echo \$(tantan --version 2>&1) | sed 's/^tantan //' > ${software}.version.txt
    """
}
