// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process GENOMICBREAKS_STATS {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

//    conda (params.enable_conda ? "YOUR-TOOL-HERE" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "/bucket/LuscombeU/common/Singularity/GenomicBreaks.sif"
    } else {
        error "Only the local Singularity image is supported"
//        container "quay.io/biocontainers/YOUR-TOOL-HERE"
    }

    input:
    tuple val(meta), path(axt), path(gff)
    path(skel)

    output:
    tuple val(meta), path("*.yaml"), emit: yaml
    path "*.html"                  , emit: html
    path "*.version.txt"           , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    cp ${skel} not-a-symbolic-link.Rmd
    R -e 'rmarkdown::render(
        "not-a-symbolic-link.Rmd",
        output_file = "./${prefix}.html",
        params = list(axtFile = "${axt}", gffFile = "${gff}", prefix = "${prefix}"))'

    echo '0.0.0' > ${software}.version.txt
    """
}
