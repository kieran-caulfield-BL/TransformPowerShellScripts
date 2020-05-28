$java="$env:JAVA_HOME\bin\java.exe"
$saxon="C:\Users\kieran.caulfield\SAXON\saxon9he.jar"
$xml="C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Spool\XML\V3PR_DumpFileFormatted.xml"
$xslt="C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Development\DumpFileExtractAGENDA.xslt"
$output="C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Spool\CSV\V3PR_AGENDA.csv"
$notepad = 'C:\windows\system32\notepad.exe'


$argumentList = ('-jar ' +""""+$saxon+""""+' -t -s:'+""""+$xml+""""+' -xsl:'+""""+$xslt+""""+' -o:'+""""+$output+""""+' --suppressXsltNamespaceCheck:on')
Write-Output $argumentList

$errorLog = 'C:\Users\kieran.caulfield\SAXON\stderr_CSV.txt'

Start-Process -FilePath $java `
-ArgumentList $argumentList -PassThru -RedirectStandardError $errorLog -wait

Start-Process $notepad -ArgumentList $errorLog -wait