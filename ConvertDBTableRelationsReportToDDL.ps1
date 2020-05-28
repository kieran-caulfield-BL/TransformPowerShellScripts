# XSL Transformer

function Replace-AllStringsInFile($SearchString,$ReplaceString,$FullPathToFile)
{
    $content = [System.IO.File]::ReadAllText("$FullPathToFile").Replace("$SearchString","$ReplaceString")
    [System.IO.File]::WriteAllText("$FullPathToFile", $content)
}

$XslPath = "C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Development\TableRelationsReportTransformDDL.xslt"
$XmlPath = "C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Spool\XML\SOSTableRelationsReport.xml"
$HtmlOutput = "C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Spool\DDL\TableRelationsReport_SOS.DDL.sql"

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

