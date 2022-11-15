// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process filter_mapped_reads {
    // See https://github.com/luslab/oist-assembler/blob/keepHapOpt/workflows/filter_mapped_reads/local_process.nf
    tag "$meta.id"
    label 'process_medium'

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
        tuple val(meta), path(reads), path(alignment)

    output:
        tuple val(meta), path("*.reads_kept.fq"), emit: fastq
        path "*.version.txt"             , emit: version

    script:
        def software = getSoftwareName(task.process)
        def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
        // List reads to remove
        make_read_list  = "zgrep ^s ${alignment} | cut -f 2 -d' ' | sed -n 2~2p | sort | uniq > reads_to_remove"
        // Functions to convert FASTQ to and from one-line intermediary format.
        to_one_line      = "toOneLine() { paste <(sed -n 1~4p \$1) <(sed -n 2~4p \$1) <(sed -n 3~4p \$1) <(sed -n 4~4p \$1) ; }"
        to_four_lines    = "toFourLines() { sed 's/\\t/\\n/g' ; }"
        // Remove reads matching haplotypes scaffolds from original reads.
        filter_reads = "toOneLine unzipped_reads | grep -v -f reads_to_remove | toFourLines > ${prefix}.reads_kept.fq"

        //SHELL
        """
        ${make_read_list}
        ${to_one_line}
        ${to_four_lines}
        zcat ${reads} > unzipped_reads
        ${filter_reads}

        echo "0.0.0" > ${software}.version.txt
        """
}
