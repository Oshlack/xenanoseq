process XENOMAPPER {
    debug true
    tag "xeno"
    label 'process_single'

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'file://../xenanoseq/lib/xenomapper_image/xenomapper.sif' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    tuple val(commonkey), val(meta), path(bam), val(meta_mouse), path(bam_mouse)

    output:
    tuple val(meta), path("*.sam"), emit: xenomapped_sams
    path '*.csv'       , emit: csv

    when:
    task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in nf-core/nanoseq/bin/
    """

    xenomapper --primary_bam $bam --secondary_bam $bam_mouse  --primary_specific ${commonkey}.human.sam  --secondary_specific ${commonkey}.mouse.sam --primary_multi ${commonkey}.human_multi.sam --secondary_multi ${commonkey}.mouse_multi.sam --unassigned ${commonkey}.unassigned.sam --unresolved ${commonkey}.unresolved.sam 2>&1 | tee -a xenoresults.${commonkey}.csv
    """
}


