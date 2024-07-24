process XENOMAPPER {
    debug true
    tag "xeno"
    label 'process_single'

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'file://xenanoseq/lib/xenomapper_image/xenomapper2.sif' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    tuple val(commonkey), val(meta), path(bam), val(meta_mouse), path(bam_mouse)

    output:
    tuple val(meta), path("*.bam"), emit: xenomapped_bams
    path '*.csv'       , emit: csv

    when:
    task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in nf-core/nanoseq/bin/
    """

    xenomapper2 --primary $bam --secondary $bam_mouse  --primary-specific ${commonkey}.human.bam  --secondary-specific ${commonkey}.mouse.bam --primary-multi ${commonkey}.human_multi.bam --secondary-multi ${commonkey}.mouse_multi.bam --unassigned ${commonkey}.unassigned.bam --unresolved ${commonkey}.unresolved.bam 2>&1 | tee -a xenoresults.${commonkey}.csv
    """
}


