// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process SEQTK_CUTN {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::seqtk=1.4" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/seqtk:1.4--he4a0461_1"
    } else {
        container "quay.io/biocontainers/seqtk:1.4--he4a0461_1"
    }

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.bed"), emit: bed
    path "*.version.txt"             , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    seqtk \\
      cutN \\
      $options.args \\
      -g $fasta \\
      > ${prefix}.bed

    echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//' > ${software}.version.txt
    """
}
