# set the file path for the output
$filePath = "C:\Users\kieran.caulfield\My Documents\SolCaseScreen.xml"

# Create The Document
$XmlWriter = New-Object System.XMl.XmlTextWriter($filePath,$Null)

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

# Write the Document
$xmlWriter.WriteStartElement("Servers")
$xmlWriter.WriteElementString("Name","SERVER01")
$xmlWriter.WriteElementString("IP","10.30.23.45")
$xmlWriter.WriteEndElement # <-- Closing Servers

# Write Close Tag for Root Element
$xmlWriter.WriteEndElement # <-- Closing RootElement

# End the XML Document
$xmlWriter.WriteEndDocument()

# Finish The Document
$xmlWriter.Finalize
$xmlWriter.Flush
$xmlWriter.Close()