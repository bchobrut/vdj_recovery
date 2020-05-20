#!/bin/bash
#SBATCH --job-name=TemplateSearchParallel
#SBATCH --time=10:00:00
#Time average of 3 minutes seconds per file per core for 7 receptors
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wtong@health.usf.edu
#SBATCH --constraint="cpu_xeon&sse4"
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH --mem=3000

bamFolder="$WORK/BRCA_TP_500"

#comment/uncomment one of the lines below for cases where "chr" is required in the search script
#chr=""
chr="chr"

samtoolsBin="$HOME/bin/samtools"
parallelBin="$HOME/bin/parallel"
numCores="8"

if [ $# -eq 1 ]; then
	bamFolder=${1%/}
fi

echo `date +"%a %x %X"`

regionTRA="${chr}14:20000000-24000000"
regionTRB="${chr}7:140000000-145000000"
regionTRD="${chr}14:20000000-25000000"
regionTRG="${chr}7:36000000-41000000"
regionIGH="${chr}14:103000000-107349000"
regionIGK="${chr}2:86000000-92000000"
regionIGL="${chr}22:21000000-25000000"

echo "Fetching file list..."
fileList=`find $bamFolder -type f -name "*.bam" ! -name "*unmapped*" ! -name "*TRA.bam" ! -name "*TRB.bam" ! -name "*TRD.bam" ! -name "*TRG.bam" ! -name "*IGH.bam" ! -name "*IGK.bam" ! -name "*IGL.bam"`

echo "Extracting TRA..."
$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionTRA -o {1.}_TRA.bam" ::: "${fileList[@]}"
echo "Extracting TRB..."
$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionTRB -o {1.}_TRB.bam" ::: "${fileList[@]}"
echo "Extracting TRD..."
$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionTRD -o {1.}_TRD.bam" ::: "${fileList[@]}"
echo "Extracting TRG..."
$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionTRG -o {1.}_TRG.bam" ::: "${fileList[@]}"
echo "Extracting IGH..."
$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionIGH -o {1.}_IGH.bam" ::: "${fileList[@]}"
echo "Extracting IGK..."
$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionIGK -o {1.}_IGK.bam" ::: "${fileList[@]}"
echo "Extracting IGL..."
$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionIGL -o {1.}_IGL.bam" ::: "${fileList[@]}"

echo "Done"

echo `date +"%a %x %X"`