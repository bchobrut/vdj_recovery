#!/bin/bash
#SBATCH --job-name=ExtractUnmapped
#SBATCH --time=2:00:00
# time is about 8 minutes average, so plan for 10, divide by number of cores, so 50 files ~ 2 hours on 4 nodes
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

echo "Fetching file list..."
fileList=`find $bamFolder -type f -name "*.bam" ! -name "*unmapped*" ! -name "*TRA.bam" ! -name "*TRB.bam" ! -name "*TRD.bam" ! -name "*TRG.bam" ! -name "*IGH.bam" ! -name "*IGK.bam" ! -name "*IGL.bam"`
numBams=`find $bamFolder -type f -name "*.bam" ! -name "*unmapped*"  ! -name "*TRA.bam" ! -name "*TRB.bam" ! -name "*TRD.bam" ! -name "*TRG.bam" ! -name "*IGH.bam" ! -name "*IGK.bam" ! -name "*IGL.bam" -printf '.' | wc -c`
numUM=`find $bamFolder -type f -name "*unmapped.bam" -printf '.' | wc -c`

echo "Found $numBams bam files and $numUM unmapped bam files..."

if [ "$numBams" -ne "$numUM" ]; then
	$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -f4 -h {1} -o {1.}_unmapped.bam" ::: "${fileList[@]}"
fi

echo `date +"%a %x %X"`