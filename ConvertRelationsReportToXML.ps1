# Script to read a SolCase DMP file and format it's contents into XML output

# set the input file path

$inFile = 'C:\Users\kieran.caulfield\Birkett Long LLP\IT Team - Documents\IT Share\Transformation\Data Modelling\DBRelationsReport_SOS'

# set the file path for the output

$outFile = "C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Spool\XML\SOSTableRelationsReport.xml"

# Create The Document

$XmlWriter = New-Object System.XMl.XmlTextWriter($outFile,$Null)

# Set The Formatting

$xmlWriter.Formatting = "Indented"
$xmlWriter.Indentation = 1

# Write the XML Decleration

$xmlWriter.WriteStartDocument() 

# Set the XSL

$XSLPropText = "type='text/xsl' href='style.xsl'"

$xmlWriter.WriteProcessingInstruction("xml-stylesheet", $XSLPropText)

# Write Root Element

$xmlWriter.WriteStartElement("SOLDB")

#initialise node group flags

$closeNodeGroup = $false
$thisRelationName = ''
$previousRelationName = ''


$tableFlagOn = $false
$fieldFlagOn = $false


$patternPipe = [RegEx]::Escape("|")


$relationStart = "[\w]+(\:)"

$fkKeyLine = "(.*OF\W)"
$fkKeyName = "(^p.*-INDEX\W)"
$fkKeyMissing = "(No relations\W)"

# Open the dump file

$data = Get-Content $inFile 

$data | ForEach {

    If ($_ -match $relationStart) {

        # get rid of equals signs
        echo "$_"     
        $envVarArr = $_.split(":")
        $thisRelationName = $envVarArr[0].Trim()

        echo "this relationship name: $thisRelationName"
        echo "prev relationship name: $previousRelationName"

        If ($thisRelationName -ne $previousRelationName) {       
            
            If($previousRelationName -ne '') {
                $xmlWriter.WriteFullEndElement()  # TABLE  
                echo "Close relationship name: $previousRelationName"  
                $tableFlagOn = $false  
            }

            $xmlWriter.WriteStartElement("CONSTRAINT")
            echo "Write constraint name: $thisRelationName"
            $tableFlagOn = $true

            $xmlWriter.WriteAttributeString("ConstraintName", $thisRelationName)
               
            $previousRelationName = $thisRelationName
       } 

    } # table start

     If ($_ -match $fkKeyLine) {
            
            echo "$_"

            $envVarArr = $_.split("(")

            $xmlWriter.WriteStartElement("FOREIGN-KEY")
            $xmlWriter.WriteAttributeString("FKKeyName",$envVarArr[0].Trim())
            $reference = $envVarArr[0].Substring($envVarArr[0].IndexOf(" OF")+4)

                  $xmlWriter.WriteStartElement("REFERENCE")
                     $reference = $reference.Trim()
                     $xmlWriter.WriteAttributeString("ReferenceName",$reference)
                  $xmlWriter.WriteEndElement()

                $envVarArr2 = $envVarArr[1].Split(",")
                    $envVarArr2 | ForEach-Object {
                        $xmlWriter.WriteStartElement("KEYS")
                            $keyVal = $_.Trim()
                            $xmlWriter.WriteAttributeString("KeyName",$keyVal.TrimEnd(")"))
                        $xmlWriter.WriteEndElement()
                    }
            $xmlWriter.WriteFullEndElement() # FOREIGN-KEY
     } # FK Field Name

    If ($_ -match $fkKeyMissing) {
            
            echo "$_"

            $xmlWriter.WriteStartElement("FOREIGN-KEY")
            $xmlWriter.WriteAttributeString("FKKeyName","NOKEY")
            $xmlWriter.WriteFullEndElement() # FOREIGN-KEY
     } # FK Field Name


} # For Each

# Write the Document
# Write Close Tag for Root Element

$xmlWriter.WriteFullEndElement() # <-- Last CONSTRAINT
$xmlWriter.WriteFullEndElement() # <-- Closing RootElement

# End the XML Document

$xmlWriter.WriteEndDocument() 

# Finish The Document

$xmlWriter.Finalize

$xmlWriter.Flush

$xmlWriter.Close()