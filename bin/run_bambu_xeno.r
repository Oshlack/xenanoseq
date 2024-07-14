#!/usr/bin/env Rscript

################################################
################################################
## REQUIREMENTS                               ##
################################################
################################################

## TRANSCRIPT ISOFORM DISCOVERY AND QUANTIFICATION
    ## - ALIGNED READS IN BAM FILE FORMAT
    ## - GENOME SEQUENCE
    ## - ANNOTATION GTF FILE
    ## - THE PACKAGE BELOW NEEDS TO BE AVAILABLE TO LOAD WHEN RUNNING R

################################################
################################################
## LOAD LIBRARY                               ##
################################################
################################################
library(bambu)
#install.packages("readr", repos="https://cloud.r-project.org")
#library(readr)

################################################
################################################
## PARSE COMMAND-LINE PARAMETERS              ##
################################################
################################################
args = commandArgs(trailingOnly=TRUE)

output_tag     <- strsplit(grep('--tag*', args, value = TRUE), split = '=')[[1]][[2]]
ncore          <- strsplit(grep('--ncore*', args, value = TRUE), split = '=')[[1]][[2]]
genomeseq      <- strsplit(grep('--fasta*', args, value = TRUE), split = '=')[[1]][[2]]
genomeSequence <- Rsamtools::FaFile(genomeseq)
Rsamtools::indexFa(genomeseq)
annot_gtf      <- strsplit(grep('--annotation*', args, value = TRUE), split = '=')[[1]][[2]]
readlist       <- args[5:length(args)]

################################################
################################################
## RUN BAMBU                                  ##
################################################
################################################
grlist <- prepareAnnotations(annot_gtf)

#TODO add ndr value to script - not needed reallyt if rcOUtDir done
# TODO rcOutDir = "path/to/rcOutput/", and add to nextflow process
se     <- bambu(reads = readlist, annotations = grlist, genome = genomeSequence, ncore = ncore, verbose = TRUE)
writeBambuOutput(se, output_tag,prefix="xeno_")
saveRDS(se, paste(output_tag,"xeno_bambu_summ_exp.rds",sep="/"))
