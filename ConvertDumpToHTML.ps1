# XSL Transformer

function Replace-AllStringsInFile($SearchString,$ReplaceString,$FullPathToFile)
{
    $content = [System.IO.File]::ReadAllText("$FullPathToFile").Replace("$SearchString","$ReplaceString")
    [System.IO.File]::WriteAllText("$FullPathToFile", $content)
}

$XslPath = "C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Development\DumpFileTransform.xslt"
$XmlPath = "C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Spool\XML\V2DP_DumpFileFormatted.xml"
$HtmlOutput = "C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Spool\HTML\V2DP_DumpFileFormatted.html"

try
{
    $arglist = new-object System.Xml.Xsl.XsltArgumentList
    $XsltSettings = New-Object System.Xml.Xsl.XsltSettings($true,$true)
    $XmlUrlResolver = New-Object System.Xml.XmlUrlResolver
    $XslPatht = New-Object System.Xml.Xsl.XslCompiledTransform
    $XslPatht.Load($XslPath, $XsltSettings, $XmlUrlResolver)
    $XslPatht.Transform($XmlPath, $HtmlOutput)
     
    Write-Host "Generated output is on path: $HtmlOutput"
}
catch
{
    Write-Host $_.Exception -ForegroundColor Red
}

# post processing on text to make is render properly in the html file

Replace-AllStringsInFile "&lt;BR/&gt;" "<BR/>" $HtmlOutput

