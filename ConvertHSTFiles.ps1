# Convert HST word Docs into HTML/TXT for easier reading

$docPath = 'C:\Users\kieran.caulfield\Documents\V3PR-FileDump\'

$srcfiles = Get-ChildItem $docPath -filter "*.HST"
$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatDOSText");
$word = new-object -comobject word.application
$word.Visible = $False
		
function saveas-TXT
	{
		$opendoc = $word.documents.open($doc.FullName);
		$opendoc.saveas([ref]"$docPath\Converted\$doc.txt", [ref]$saveFormat);
		$opendoc.close();
	}
	
ForEach ($doc in $srcfiles)
	{
		Write-Host "Processing :" $doc.FullName
		saveas-TXT
		$doc = $null
	}

$word.quit();