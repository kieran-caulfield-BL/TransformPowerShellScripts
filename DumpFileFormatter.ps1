# Script to rea da SolCase DMP file and format it's contents into XML output
# set the input file path
$inFile = 'C:\Users\kieran.caulfield\AppData\Local\Temp\SOLTMP\KIERANC\V2GA_General-Screns-Agnda.DMP'
# set the file path for the output
$outFile = "C:\Users\kieran.caulfield\Documents\Development\DumpFileFormatted.xml"

# Create The Document
$XmlWriter = New-Object System.XMl.XmlTextWriter($outFile,$Null)

# Set The Formatting
$xmlWriter.Formatting = "Indented"
$xmlWriter.Indentation = "4"

# Write the XML Decleration
$xmlWriter.WriteStartDocument()

# Set the XSL
$XSLPropText = "type='text/xsl' href='style.xsl'"
$xmlWriter.WriteProcessingInstruction("xml-stylesheet", $XSLPropText)

# Write Root Element
$xmlWriter.WriteStartElement("RootElement")

# Open the dump file
Get-Content $inFile | ForEach-Object {

    $envVarArr = $_.ToString().Split('","')
    echo "Line Read " +$envVarArr[0]

    If ($envVarArr[0] -eq "AT") {
            # This is beginning of a document definition
            echo "AGENDA-TYPE $envVarArr[0] $envVarArr[1]" 
            $xmlWriter.WriteStartElement("AGENDA-TYPE");
            $xmlWriter.WriteAttributeString($envVarArr[0], $envVarArr[1]);
     }

     If ($envVarArr[0] -eq "DE") {
            # This is 2nd line of definition
            $xmlWriter.WriteStartElement("DESC");
            $xmlWriter.WriteString($envVarArr[1]);     
            # now close the XML Node Group
            $xmlWriter.WriteEndElement  # DESC
            $xmlWriter.WriteEndElement  # AGENDA-TYPE
     }
    

} # For Each

# Write the Document

# Write Close Tag for Root Element
$xmlWriter.WriteEndElement # <-- Closing RootElement

# End the XML Document
$xmlWriter.WriteEndDocument()

# Finish The Document
$xmlWriter.Finalize
$xmlWriter.Flush
$xmlWriter.Close()