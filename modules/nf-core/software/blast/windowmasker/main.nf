// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process BLAST_WINDOWMASKER {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? 'bioconda::blast=2.15.0' : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container 'https://depot.galaxyproject.org/singularity/blast:2.15.0--pl5321h6f7f691_1'
    } else {
        container 'quay.io/biocontainers/blast:2.15.0--pl5321h6f7f691_1'
    }

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('*.fasta.gz'),  emit: fasta
    path '*.version.txt',           emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    # Erase original masking
    perl -pe ' next if />/ ; \$_ = uc' $fasta > uppercased.fasta
    # Mask with windowmasker
    windowmasker -mk_counts -in uppercased.fasta > genome.wmstat
    windowmasker -ustat genome.wmstat -outfmt fasta -in uppercased.fasta | gzip > ${prefix}.fasta.gz # --no-name option unavailable on busybox :(
    windowmasker -version | head -n1 | sed 's/^.*windowmasker: //' > ${software}.version.txt
    """
}
