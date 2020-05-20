#!/bin/bash
#SBATCH --job-name=TemplateSearchIgTcR
#SBATCH --time=168:00:00
#Notes below for how to estimate time based on what processes need to be run
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wtong@health.usf.edu
#SBATCH --constraint="cpu_xeon&sse4"
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH --mem=4096
#Max RAM usage ~7x the largest .tsv generated times number of cores; so 4 cores is 28*largest tsv
#TODO:	- Warn if # of index files look wrong
#		- Store last read/result and compare against it to reduce IMGT queries

#161029 Extract unmapped regions
#161028 Change to use new Search J method
#160719 Use GNU parallel: Remember to cite O. Tange (2011): GNU Parallel - The Command-Line Power Tool, ;login: The USENIX Magazine, February 2011:42-47.
#160719 Combine lines to automatically extract only file name
#160715 change Ig to variable and make the folders automatically

############################################################################################################################
#set file paths
bamFolder="$yaping/PRAD_TP"

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
#so total time = 
#Give extra 25% in case of hyperthreading vs physical cores
#toDo=("imgtSearch")
toDo=("quickcheck" "extractUnmapped" "extractReceptors" "runSearches" "tsv2xlsx" "imgtSearch")

#don't set above the number of cores on the node, make sure if on circe, do NOT exceed ntasks-per-node above
#4 is best for scheduling
numCores="4"
#numCores=`nproc`

#comment/uncomment one of the lines below for cases where "chr" is required in the search script
#chr=""
chr="chr"
############################################################################################################################

imgtSearch="/shares/blanck_group/shared/imgtSearchIgTcr.php"
searchScript="/shares/blanck_group/shared/SearchReads.sh"

#Set bin paths
tsv2xlsx="/shares/blanck_group/shared/tsv2xlsx.php"
samtoolsBin="/shares/blanck_group/shared/bin/samtools"
parallelBin="/shares/blanck_group/shared/bin/parallel"
phpBin="/shares/blanck_group/shared/bin/php"
pigz="/shares/blanck_group/shared/bin/pigz"


#can use this script as "sh Template_TP_Search_Parallel.sh PATH_TO_BAM_FOLDER"
#1%/ automatically removes trailing slash if it exists
if [ $# -eq 1 ]; then
	bamFolder=${1%/}
fi

samplesName="${bamFolder##*/}"

#Start the processing
echo "Starting up..."
echo `date +"%a %x %X"`

#Make results folder
resultsDir="${bamFolder}_Results"
#resultsDir="${HOME}/${samplesName}_Results"

#Make the results folders for each receptor
echo "Making folders..."
echo `date +"%a %x %X"`

mkdir -p $resultsDir

for IgTcr in "${IgTcrs[@]}"
do
	resultsDirIgTcr="${resultsDir}/$IgTcr"

	mkdir -p $resultsDirIgTcr
done

##############################################################

echo "Fetching file list..."
echo `date +"%a %x %X"`

#Get list of file paths
#Check if Ig/TCR array requires unmapped reads
if [[ "${toDo[*]}" == *extractUnmapped* ]]; then
	if [[ "${IgTcrs[*]}" == *UM* ]]; then
		numBams=`find $bamFolder -type f -name "*.bam" ! -name "*unmapped*"  ! -name "*TRA.bam" ! -name "*TRB.bam" ! -name "*TRD.bam" ! -name "*TRG.bam" ! -name "*IGH.bam" ! -name "*IGK.bam" ! -name "*IGL.bam" -printf '.' | wc -c`
		numUM=`find $bamFolder -type f -name "*unmapped.bam" -printf '.' | wc -c`
		echo "Found $numBams bam files and $numUM unmapped bam files..."

		if [ "$numBams" -ne "$numUM" ]; then
			echo "Extracting unmapped regions..."
			fileListM=`find ${bamFolder} -type f -name "*.bam" ! -name "*unmapped*"  ! -name "*TRA.bam" ! -name "*TRB.bam" ! -name "*TRD.bam" ! -name "*TRG.bam" ! -name "*IGH.bam" ! -name "*IGK.bam" ! -name "*IGL.bam"`
			$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -f4 {1} -h -o {1.}_unmapped.bam" ::: "${fileListM[@]}"
		fi
	fi
fi

##############################################################

if [[ "${toDo[*]}" == *extractReceptors* ]]; then
	echo "Extracting receptor regions..."
	echo `date +"%a %x %X"`
	regionTRA="${chr}14:20000000-24000000"
	regionTRB="${chr}7:140000000-145000000"
	regionTRD="${chr}14:20000000-25000000"
	regionTRG="${chr}7:36000000-41000000"
	regionIGH="${chr}14:103000000-107349000"
	regionIGK="${chr}2:86000000-92000000"
	regionIGL="${chr}22:21000000-25000000"

	fileListM=`find ${bamFolder} -type f -name "*.bam" ! -name "*unmapped*"  ! -name "*TRA.bam" ! -name "*TRB.bam" ! -name "*TRD.bam" ! -name "*TRG.bam" ! -name "*IGH.bam" ! -name "*IGK.bam" ! -name "*IGL.bam"`
	echo "Extracting TRA..."
	$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionTRA -o {1.}_TRA.bam" ::: "${fileListM[@]}"
	echo "Extracting TRB..."
	$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionTRB -o {1.}_TRB.bam" ::: "${fileListM[@]}"
	echo "Extracting TRD..."
	$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionTRD -o {1.}_TRD.bam" ::: "${fileListM[@]}"
	echo "Extracting TRG..."
	$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionTRG -o {1.}_TRG.bam" ::: "${fileListM[@]}"
	echo "Extracting IGH..."
	$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionIGH -o {1.}_IGH.bam" ::: "${fileListM[@]}"
	echo "Extracting IGK..."
	$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionIGK -o {1.}_IGK.bam" ::: "${fileListM[@]}"
	echo "Extracting IGL..."
	$parallelBin -j${numCores} --eta  "$samtoolsBin view -b -h {1} $regionIGL -o {1.}_IGL.bam" ::: "${fileListM[@]}"
fi

##############################################################
if [[ "${toDo[*]}" == *quickcheck* ]]; then
	echo "Running quickcheck..."
	echo `date +"%a %x %X"`
	numBams=`find $bamFolder -type f -name "*.bam" ! -name "*unmapped*"  ! -name "*TRA.bam" ! -name "*TRB.bam" ! -name "*TRD.bam" ! -name "*TRG.bam" ! -name "*IGH.bam" ! -name "*IGK.bam" ! -name "*IGL.bam" -printf '.' | wc -c`
	numBais=`find $bamFolder -type f -name "*.bai" -printf '.' | wc -c`

	echo "numBams = $numBams"
	echo "numBais = $numBais"

	if [ "$numBams" -ne "$numBais" ]; then
		echo "Error: Some index files are missing. Exiting."
		exit
	fi

	echo "Fetching file list..."
	fileList=`find $bamFolder -type f -name "*.bam"`

	for bamFile in "${fileList[@]}"
	do
		$samtoolsBin quickcheck -v $bamFile
	done
fi
##############################################################
if [[ "${toDo[*]}" == *runSearches* ]]; then
	echo "Running Searches..."
	echo `date +"%a %x %X"`

	fileListUM=`find ${bamFolder} -type f -name "*unmapped.bam"`
	fileListM=`find ${bamFolder} -type f -name "*.bam" ! -name "*unmapped*"  ! -name "*TRA.bam" ! -name "*TRB.bam" ! -name "*TRD.bam" ! -name "*TRG.bam" ! -name "*IGH.bam" ! -name "*IGK.bam" ! -name "*IGL.bam"`

	for IgTcr in "${IgTcrs[@]}"
	do
		echo "Processing $IgTcr..."
		echo `date +"%a %x %X"`
		if [[ "$IgTcr" == *UM* ]]; then
			$parallelBin -j${numCores} --eta "sh $searchScript $samtoolsBin {1} ${resultsDir}/${IgTcr}/{1/}.tsv ${IgTcr} ${chr}" ::: "${fileListUM[@]}"
		else
			$parallelBin -j${numCores} --eta "sh $searchScript $samtoolsBin {1} ${resultsDir}/${IgTcr}/{1/}.tsv ${IgTcr} ${chr}" ::: "${fileListM[@]}"
		fi
	done
fi
##############################################################

if [[ "${toDo[*]}" == *tsv2xlsx* ]]; then
	echo "Running tsv2xlsx..."
	echo `date +"%a %x %X"`

	for IgTcr in "${IgTcrs[@]}"
	do
		echo "Running tsv2xlsx ${IgTcr}..."
		echo `date +"%a %x %X"`

		mkdir -p "${resultsDir}_xlsx/$IgTcr"

		if [[ "$IgTcr" == *UM* ]]; then
			$parallelBin -j${numCores} --eta "$phpBin $tsv2xlsx $resultsDir/${IgTcr}/{1/}.tsv ${resultsDir}_xlsx/${IgTcr}/{1/}.xlsx" ::: "${fileListUM[@]}"
		else
			$parallelBin -j${numCores} --eta "$phpBin $tsv2xlsx $resultsDir/${IgTcr}/{1/}.tsv ${resultsDir}_xlsx/${IgTcr}/{1/}.xlsx" ::: "${fileListM[@]}"
		fi
	done
fi

##############################################################
if [[ "${toDo[*]}" == *imgtSearch* ]]; then
	echo "Running IMGT Search..."
	echo `date +"%a %x %X"`

	for IgTcr in "${IgTcrs[@]}"
	do
		echo "Running IMGT for ${IgTcr}..."
		echo `date +"%a %x %X"`
		$phpBin $imgtSearch $resultsDir/${IgTcr} $resultsDir/${samplesName}_${IgTcr}_vjMatchList.tsv ${IgTcr}
		if [[ "${toDo[*]}" == *tsv2xlsx* ]]; then
			$phpBin $tsv2xlsx $resultsDir/${samplesName}_${IgTcr}_vjMatchList.tsv ${resultsDir}_xlsx/${samplesName}_${IgTcr}_vjMatchList.xlsx
		fi
	done
fi

##############################################################

#tar -I $pigz -cf ${resultsDir}.tar.gz ${resultsDir}
echo "Finished."
echo `date +"%a %x %X"`