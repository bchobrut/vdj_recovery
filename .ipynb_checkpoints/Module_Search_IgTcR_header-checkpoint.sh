#!/bin/bash
############################################################################################################################
#set file paths
bamFolder="/mnt/"

#Set which IgTcrs to process
#IgTcrs=("TRA" "TRB")
IgTcrs=("IGH" "IGK" "IGL" "TRA" "TRB" "TRD" "TRG" "IGH_UM" "IGK_UM" "IGL_UM" "TRA_UM" "TRB_UM" "TRD_UM" "TRG_UM")
#IgTcrs=()

#Set what needs to be executed, tsv2xlsx requires a lot of RAM so adjust accordingly
#extractUnmapped is about 8 minutes per file per core
#extractReceptors is about 2 minutes per file per core
#quickcheck is 1 second per file per core
#runSearches is 40 seconds per file per core for all receptors
#tsv2xlsx is 10 seconds per file per core
#so total time estimation is about 7 days for 5 TB/500 files
#Give extra 25% in case of hyperthreading vs physical cores
toDo=("quickcheck" "extractUnmapped" "extractReceptors" "runSearches")
#don't set above the number of cores on the node
numCores="4"
#numCores=`nproc`

#comment/uncomment one of the lines below for cases where "chr" is required in the search script
#chr=""
chr="chr"

############################################################################################################################

source /vdj_recovery/shared/Module_Search_IgTcR.sh
