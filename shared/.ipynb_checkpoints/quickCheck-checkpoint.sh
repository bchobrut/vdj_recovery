#!/bin/bash
#SBATCH --job-name=TemplateSearchParallel
#SBATCH --time=10:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wtong@health.usf.edu
#SBATCH --constraint="cpu_xeon&sse4"
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH --mem=3000

bamFolder="$WORK/BRCA_TP_500"
samtoolsBin="$HOME/bin/samtools"
parallelBin="$HOME/bin/parallel"
numCores="8"

if [ $# -eq 1 ]; then
	bamFolder=${1%/}
fi

echo `date +"%a %x %X"`

numBams=`find $bamFolder -type f -name "*.bam" ! -name "*unmapped*"  ! -name "*TRA.bam" ! -name "*TRB.bam" ! -name "*TRD.bam" ! -name "*TRG.bam" ! -name "*IGH.bam" ! -name "*IGK.bam" ! -name "*IGL.bam" -printf '.' | wc -c`
numBais=`find $bamFolder -type f -name "*.bai" -printf '.' | wc -c`

echo "numBams = $numBams"
echo "numBais = $numBais"

echo "Fetching file list..."
fileList=`find $bamFolder -type f -name "*.bam"`

for bamFile in "${fileList[@]}"
do
	$samtoolsBin quickcheck -v $bamFile
done

echo "Done."
echo `date +"%a %x %X"`