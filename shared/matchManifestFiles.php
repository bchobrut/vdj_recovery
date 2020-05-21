<?PHP
#170618 - wtong: Switched to assoc arrays
ini_set('memory_limit','3999M');
set_time_limit(2592000);
ini_set('max_execution_time', 2592000);
error_reporting(E_ALL);


if(!isset($argv[1],$argv[2]) || $argv[1] == $argv[2])
{
	die("Error: Must specify the JSON and manifest files");
}

if(!file_exists($argv[1]))
{
	die("Error: " . $argv[1] . " does not exist");
}
if(!file_exists($argv[2]))
{
	die("Error: " . $argv[2] . " does not exist");
}

$fileExt1 = strtolower(pathinfo($argv[1], PATHINFO_EXTENSION));
$fileExt2 = strtolower(pathinfo($argv[2], PATHINFO_EXTENSION));

$jsonFilePath = "";
$manifestFilePath = "";

if($fileExt1 == "json")
{
	$jsonFilePath = $argv[1];
	$manifestFilePath = $argv[2];
}
elseif($fileExt2 == "json")
{
	$jsonFilePath = $argv[2];
	$manifestFilePath = $argv[1];
}
else
{
	die("Error: no json file specified");
}

if(strtolower(substr($manifestFilePath, -4,4) != ".txt"))
{
	die("Error: no valid manifest file ending with .txt found.");
}

$jsonFile = json_decode(file_get_contents($jsonFilePath), true);
$manifestFile = file($manifestFilePath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);


$outputFH = fopen(substr($manifestFilePath, 0,-4) . "_barcodes.txt", "w");

$firstLoop = TRUE;
foreach($manifestFile as $manifestLine)
{
	fwrite($outputFH, $manifestLine . "\t");

	if($firstLoop)
	{
		$firstLoop = FALSE;
		fwrite($outputFH, "Barcode\n");
		continue;
	}

	$md5 = explode("\t",$manifestLine);
	$md5 = $md5[2];

	foreach($jsonFile as $jsonArr)
	{
		if($md5 == $jsonArr["md5sum"])
		{
			fwrite($outputFH, $jsonArr["associated_entities"][0]["entity_submitter_id"]);
			break;
		}
	}
	fwrite($outputFH, "\n");
}

fclose($outputFH);

?>