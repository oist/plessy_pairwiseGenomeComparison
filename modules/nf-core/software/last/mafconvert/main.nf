// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process LAST_MAFCONVERT {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::last=1250" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/last:1250--h2e03b76_0"
    } else {
        container "quay.io/biocontainers/last:1250--h2e03b76_0"
    }

    input:
    tuple val(meta), path(maf)
    val(format)

    output:
    tuple val(meta), path("*.gff.gz"), optional:true, emit: gff
    tuple val(meta), path("*.axt.gz"), optional:true, emit: axt
    path "*.version.txt"                         , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    maf-convert \\
        $format \\
        $options.args \\
        $maf | \\
        gzip > $prefix.${format}.gz

    # maf-convert has no --version option so let's use lastal from the same suite
    lastal --version | sed 's/lastal //' > ${software}.version.txt
    """
}
