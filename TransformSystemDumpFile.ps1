$java="$env:JAVA_HOME\bin\java.exe"
$saxon="C:\Users\kieran.caulfield\SAXON\saxon9he.jar"

Start-Process -FilePath $java `
-ArgumentList '-jar C:\Users\kieran.caulfield\SAXON\saxon9he.jar -t -s:"C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Spool\XML\V3PR_DumpFileFormatted.xml" -xsl:"C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Development\DumpFileTransform.xslt" -o:"C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Spool\HTML\V3PR_DumpFileFormatted.html" --suppressXsltNamespaceCheck:on' `
-PassThru -RedirectStandardError C:\Users\kieran.caulfield\SAXON\stderr.txt -wait

Start-Process 'C:\windows\system32\notepad.exe' -ArgumentList 'C:\Users\kieran.caulfield\SAXON\stderr.txt' -wait