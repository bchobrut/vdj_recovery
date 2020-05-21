<?PHP
ini_set('memory_limit','3999M');
set_time_limit(0);
ini_set('max_execution_time', 3600);
error_reporting(E_ALL);
require_once(__DIR__."/PHPExcel-1.8/Classes/PHPExcel/IOFactory.php");

if(!isset($argv[1]))
{
	die("Error: file path not specified");
}

$inputFile = $argv[1];
$outputFile = $inputFile . ".xlsx";

if(isset($argv[2]))
{
	$outputFile = $argv[2];
}

$csv = PHPExcel_IOFactory::createReader('CSV');
$csv->setDelimiter("\t");
$csv = $csv->load($inputFile);
$writer= PHPExcel_IOFactory::createWriter($csv, 'Excel2007');
$writer->save($outputFile);

?>