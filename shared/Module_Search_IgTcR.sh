searchScript="/shared/SearchReads.sh"
#Set bin paths
samtoolsBin="/shared/bin/samtools"
parallelBin="/shared/bin/parallel"

samplesName="${bamFolder##*/}"

#Start the processing
echo "Starting up..."
echo `date +"%a %x %X"`

#Make results folder
#resultsDir="${bamFolder}_Results"
resultsDir="/mnt/results/"

##############################################################

if [[ "${toDo[*]}" == *emailStart* ]]; then
	date +"%a %x %X" | mail -s "Script started" $email
fi

##############################################################

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
		echo "Warning: Some index files are missing. Indexing files..."
		echo `date +"%a %x %X"`

		fileListM=`find ${bamFolder} -type f -name "*.bam" ! -name "*unmapped*"  ! -name "*TRA.bam" ! -name "*TRB.bam" ! -name "*TRD.bam" ! -name "*TRG.bam" ! -name "*IGH.bam" ! -name "*IGK.bam" ! -name "*IGL.bam"`
		
		for bamFile in $fileListM
		do
			baseName=${bamFile%.bam}
			baiName="${baseName}.bai"

			if [ ! -e "$baiName" ]; then
				echo "Indexing ${bamFile}..."
				$samtoolsBin index $bamFile
			fi
		done
	fi

	
	fileList=`find $bamFolder -type f -name "*.bam"`
	for bamFile in $fileList
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
			$parallelBin -j${numCores} --eta "bash $searchScript $samtoolsBin {1} ${resultsDir}/${IgTcr}/{1/}.tsv ${IgTcr} ${chr}" ::: "${fileListUM[@]}"
		else
			$parallelBin -j${numCores} --eta "bash $searchScript $samtoolsBin {1} ${resultsDir}/${IgTcr}/{1/}.tsv ${IgTcr} ${chr}" ::: "${fileListM[@]}"
		fi
	done
fi