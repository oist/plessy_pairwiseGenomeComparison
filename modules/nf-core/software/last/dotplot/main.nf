// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process LAST_DOTPLOT {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::last=1541" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/last:1541--h43eeafb_0"
    } else {
        container "quay.io/biocontainers/last:1541--h43eeafb_0"
    }

    input:
    tuple val(meta), path(maf), path(bed2)
    val(format)
    path(bed1)

    output:
    tuple val(meta), path("*.gif"), optional:true, emit: gif
    tuple val(meta), path("*.png"), optional:true, emit: png
    path "*.version.txt"                         , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    last-dotplot \\
        $options.args \\
        -a $bed1 -b $bed2 \\
        $maf \\
        $prefix.$format

    # last-dotplot has no --version option so let's use lastal from the same suite
    lastal --version | sed 's/lastal //' > ${software}.version.txt
    """
}
