/*
 * Sort, index BAM file and run samtools stats, flagstat and idxstats
 */

include { SAMTOOLS_VIEW_BAM  } from '../../modules/local/samtools_view_bam'
include { SAMTOOLS_SORT      } from '../../modules/nf-core/samtools/sort/main'
include { SAMTOOLS_INDEX     } from '../../modules/nf-core/samtools/index/main'
include { SAMTOOLS_SORT_NAME } from '../../modules/local/samtools_sort_name'
include { BAM_STATS_SAMTOOLS } from '../../subworkflows/nf-core/bam_stats_samtools'

workflow BAM_SORT_NAME_SAMTOOLS {
    take:
    ch_bam // channel: [ val(meta), [ bam ] ]
    call_variants
    ch_fasta

    main:
    /*
     * Sam to bam conversion not needed
     */
    //SAMTOOLS_VIEW_BAM  ( ch_sam )
    if ( call_variants ) {
        SAMTOOLS_SORT_NAME ( ch_bam )
        ch_bam
            .join( SAMTOOLS_SORT_NAME.out.bam_bai )
            .map { it -> [ it[0], it[1], it[2], it[4] ] }
            .set { sortbam }
        //BAM_STATS_SAMTOOLS ( SAMTOOLS_SORT_NAME.out.bam, ch_fasta )
    } else {
        SAMTOOLS_SORT_NAME ( ch_bam )
        //SAMTOOLS_SORT      ( SAMTOOLS_VIEW_BAM.out.bam )
        //SAMTOOLS_INDEX     ( SAMTOOLS_SORT.out.bam )
        ch_bam
            .join( SAMTOOLS_SORT_NAME.out.bam )
            .map { it -> [ it[0], it[1], it[2], it[4] ] }
            .set { sortbam }
       // BAM_STATS_SAMTOOLS ( SAMTOOLS_SORT_NAME.out.bam, ch_fasta )
    }

    /*
     * SUBWORKFLOW: Create stats using samtools
    BAM_STATS_SAMTOOLS.out.stats
        .join ( BAM_STATS_SAMTOOLS.out.idxstats )
        .join ( BAM_STATS_SAMTOOLS.out.flagstat )
        .map  { it -> [ it[1], it[2], it[3] ] }
        .set  { sortbam_stats_multiqc }
     */
    samtools_versions = ""
//BAM_STATS_SAMTOOLS.out.versions

    emit:
    sortbam
    //sortbam_stats_multiqc
    samtools_versions
}
