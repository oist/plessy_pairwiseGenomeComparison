// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process LAST_LASTAL {
    tag "$meta.id"
    label 'process_high'

    if (! params.one_to_one_only) {
        publishDir "${params.outdir}",
            mode: params.publish_dir_mode,
            saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }
    }

    conda (params.enable_conda ? "bioconda::last=1541" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/last:1541--h43eeafb_0"
    } else {
        container "quay.io/biocontainers/last:1541--h43eeafb_0"
    }

    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(meta), path(fastx), path (param_file)
    path index

    output:
    tuple val(meta), path("*.maf.gz"), emit: maf
    path "*.version.txt"             , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def trained_params = param_file ? "-p ${param_file}"  : ''
    """
    INDEX_NAME=\$(basename -s .prj \$(ls $index/*.prj) | sort | head -n1)
    lastal \\
        $trained_params \\
        $options.args \\
        -P $task.cpus \\
        ${index}/\$INDEX_NAME \\
        $fastx \\
        | gzip --no-name > ${prefix}.maf.gz
    # gzip needs --no-name otherwise it puts a timestamp in the file,
    # which makes its checksum non-reproducible.

    echo \$(lastal --version 2>&1) | sed 's/lastal //' > ${software}.version.txt
    echo '# Make the file non-empty for grep -q' >> .command.log
    grep -qv -e oom-kill -e out-of-memory .command.log
    """
}
