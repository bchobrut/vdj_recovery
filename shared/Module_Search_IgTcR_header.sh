#!/bin/bash
#SBATCH --job-name=TemplateSearchIgTcR
#SBATCH --time=168:00:00
#Notes below for how to estimate time based on what processes need to be run

#SBATCH --constraint="cpu_xeon&sse4"
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH --mem=4096
#Max RAM usage ~7x the largest .tsv generated times number of cores; so 4 cores is 28*largest tsv

#160719 Use GNU parallel: Remember to cite O. Tange (2011): GNU Parallel - The Command-Line Power Tool, ;login: The USENIX Magazine, February 2011:42-47.

############################################################################################################################
#set file paths
bamFolder="/work/w/wtong/BRCA_TP_500"

#Set which IgTcrs to process
IgTcrs=("IGH" "IGK" "IGL" "TRA" "TRB" "TRD" "TRG" "IGH_UM" "IGK_UM" "IGL_UM" "TRA_UM" "TRB_UM" "TRD_UM" "TRG_UM")
#IgTcrs=("IGH" "IGK" "IGL" "TRA" "TRB" "TRD" "TRG" "IGH_UM" "IGK_UM" "IGL_UM" "TRA_UM" "TRB_UM" "TRD_UM" "TRG_UM")

#Set what needs to be executed, tsv2xlsx requires a lot of RAM so adjust accordingly
#imgtSearch is 20 minutes per file for all receptors combined
#extractUnmapped is about 8 minutes per file per core
#extractReceptors is about 2 minutes per file per core
#quickcheck is 1 second per file per core
#runSearches is 40 seconds per file per core for all receptors
#tsv2xlsx is 10 seconds per file per core
#so total time estimation is about 7 days for 5 TB/500 files
#Give extra 25% in case of hyperthreading vs physical cores
toDo=("quickcheck" "extractUnmapped" "extractReceptors" "runSearches" "tsv2xlsx" "imgtSearch" "emailStart" "emailEnd")
#todo=("imgtSearch")
#toDo=("quickcheck" "extractUnmapped" "extractReceptors" "runSearches" "tsv2xlsx" "imgtSearch" "emailStart" "emailEnd" "pigz" "copyToWos")

#don't set above the number of cores on the node, make sure if on circe, do NOT exceed ntasks-per-node above
#4 is best for scheduling
numCores="4"
#numCores=`nproc`

#comment/uncomment one of the lines below for cases where "chr" is required in the search script
#chr=""
chr="chr"

email="wtong@health.usf.edu"
############################################################################################################################

source /shares/blanck_group/shared/Module_Search_IgTcR.sh