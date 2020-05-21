bamFolder="/work/w/wtong/BRCA_TP_500"


numCores="8"
parallelBin="/shares/blanck_group/shared/bin/parallel"
samtoolsBin="/shares/blanck_group/shared/bin/samtools"

samplesName="${bamFolder##*/}"
resultsDir="${HOME}/${samplesName}_Results/MT"

mkdir -p $resultsDir

fileListM=`find ${bamFolder} -type f -name "*.bam" ! -name "*unmapped*"  ! -name "*TRA.bam" ! -name "*TRB.bam" ! -name "*TRD.bam" ! -name "*TRG.bam" ! -name "*IGH.bam" ! -name "*IGK.bam" ! -name "*IGL.bam"`

$parallelBin -j${numCores} --eta "$samtoolsBin view {1} chrM:1671-3229 > ${resultsDir}/{1/}.tsv" ::: "${fileListM[@]}"