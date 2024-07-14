process BAMBU_XENO {
    label 'process_medium'

    conda "conda-forge::r-base=4.0.3 bioconda::bioconductor-bambu=3.0.8 bioconda::bioconductor-bsgenome=1.66.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioconductor-bambu:3.0.8--r42hc247a5b_0' :
        'quay.io/biocontainers/bioconductor-bambu:3.0.8--r42hc247a5b_0' }"

    input:
    tuple path(fasta), path(gtf)
    path bams

    output:
    path "xeno_counts_gene.txt"         , emit: ch_gene_counts
    path "xeno_counts_transcript.txt"   , emit: ch_transcript_counts
    path "xeno_extended_annotations.gtf", emit: extended_gtf
    path "xeno_bambu_summ_exp.rds"       , emit: summ_exp
    //path "rcFiles"       , emit: rcFiles
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    run_bambu_xeno.r \\
        --tag=. \\
        --ncore=$task.cpus \\
        --annotation=$gtf \\
        --fasta=$fasta $bams

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        bioconductor-bambu: \$(Rscript -e "library(bambu); cat(as.character(packageVersion('bambu')))")
        bioconductor-bsgenome: \$(Rscript -e "library(BSgenome); cat(as.character(packageVersion('BSgenome')))")
    END_VERSIONS
    """
}
