<?PHP

define("CELL_POSITION", 9); // position of the read in the vRegion file
ini_set('memory_limit','3999M');

if(!isset($argv[1]))
{
	die("Error: Must specify tsv folder using command line:\nE.g:\n\nphp.exe tsv2fasta.php D:/Research/READ_TP_Results/IGH/ IGH D:/Research/READ_TP_Results/READ_TP_IGH");
}

$tsvFilesDir = rtrim($argv[1],"/\\")."/";

if(!file_exists($tsvFilesDir))
{
	die("Invalid folder path: $tsvFilesDir");
}

//Check if Ig or TcR
$IgTcR = "Ig";
$receptorStr = "";
if(isset($argv[2]))
{
	$receptorStr = $argv[2];
}
else
{
	$receptorStr = substr($mFilesDir,-12);
}

if(stripos($receptorStr, "IGH") !== FALSE || stripos($receptorStr, "IGK") !== FALSE || stripos($receptorStr, "IGL") !== FALSE)
{
	$IgTcR = "Ig";
	echo "Matching reads as Ig...";
}
elseif(stripos($receptorStr, "TRA") !== FALSE || stripos($receptorStr, "TRB") !== FALSE || stripos($receptorStr, "TRD") !== FALSE  || stripos($receptorStr, "TRG") !== FALSE)
{
	$IgTcR = "TcR";
	echo "Matching reads as TcR...";
}
else
{
	die("Error: Ig or TcR is not specified. Can't figure it out from this folder name: $receptorStr");
}

$table ="";
if(stripos($receptorStr, "TRA") !== FALSE)
{
	$table = "TRA";
}
elseif(stripos($receptorStr, "TRB") !== FALSE)
{
	$table = "TRB";
}
elseif(stripos($receptorStr, "TRD") !== FALSE)
{
	$table = "TRD";
}
elseif(stripos($receptorStr, "TRG") !== FALSE)
{
	$table = "TRG";
}
elseif(stripos($receptorStr, "IGH") !== FALSE)
{
	$table = "IGH";
}
elseif(stripos($receptorStr, "IGK") !== FALSE)
{
	$table = "IGK";
}
elseif(stripos($receptorStr, "IGL") !== FALSE)
{
	$table = "IGL";
}
else
{
	die("Error: Unknown receptor name '$receptorStr'");
}


//Fetch all tsv's
$tsvFilesList = glob($tsvFilesDir."*.tsv");

if(count($tsvFilesList) == 0)
{
	die("Error: Zero tsv files found in $tsvFilesList");
}

$tsvFileNames = str_ireplace($tsvFilesDir,'',$tsvFilesList);


$outputFilePath = "";
$numLines = 0;
$numOutputFiles = 1;

if(isset($argv[3]))
{
	$outputFilePath = $argv[3];
}
else
{
	$outputFilePath = $tsvFilesDir."merged".$receptorStr;
}


$outputFileName = $outputFilePath."_".$numOutputFiles.".fasta";

$output = fopen($outputFileName, 'w');

foreach($tsvFileNames as $tsvFileName)
{
	$tsvFile = file($tsvFilesDir.$tsvFileName, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

	foreach($tsvFile as $tsvLine)
	{
		$tsvLine = trim($tsvLine);
		$tsvLineArray = preg_split('/\s+/', $tsvLine);

		$read = $tsvLineArray[CELL_POSITION];
		$readID = $tsvLineArray[0];

		if(++$numLines >= 500000)
		{
			fclose($output);

			//make sure no empty lines in case input is bad
			file_put_contents($outputFileName,implode("\n", file($outputFileName, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES)));

			++$numOutputFiles;
			$numLines = 0;

			$outputFileName = $outputFilePath."_".$numOutputFiles.".fasta";

			$output = fopen($outputFileName, 'w');
		}

		fwrite($output,'>' . $readID . "\n" . $read . "\n");
	}
}

fclose($output);
file_put_contents($outputFileName,implode("\n", file($outputFileName, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES)));

?>