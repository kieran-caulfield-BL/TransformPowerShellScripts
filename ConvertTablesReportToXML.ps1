# Script to read a SolCase DMP file and format it's contents into XML output

# set the input file path

$inFile = 'C:\Users\kieran.caulfield\Birkett Long LLP\IT Team - Documents\IT Share\Transformation\Data Modelling\DBTablesReport'

# set the file path for the output

$outFile = "C:\Users\kieran.caulfield\Documents\Development\SolCaseTablesReport.xml"

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
$thisTableName = ''
$previousTableName = ''

$thisFieldname = ''
$previousFieldName = ''

$fieldFlagOn = $false

$patternPipe = [RegEx]::Escape("|")

# patterns to look for are
#    "= Table: ACCANAL =", start of the TABLE definition section
#        "= FIELD SUMMARY =" , start of the TABLE FIELDS node defn
#           "Order Field Name Data Type Flags" , start of FIELD Nodes
#           "Field Name Format" , start of formats nodes with FIELD
#           "Field Name Initial" , start of initial values nodes within FIELD
#           "Field Name Label Column Label" , start of comments values withint FIELD
#           "= FIELD DETAILS =" , start of details node within FIELD

$tableStart = "(Table:\W)"
$fieldName = "(Field Name:\W)"
$fieldNameDescription = "(Description:\W)"
$fieldNameHelp = "(Help:\W)"

# Open the dump file

$data = Get-Content $inFile 

$data | ForEach {

    If ($_ -match $tableStart) {

        # get rid of equals signs
        echo "$_"
        $removeStuff = $_ -replace '=', ''
        $envVarArr = $removeStuff.split(":")
        $thisTableName = $envVarArr[1].Trim()

        echo "this table name: $thisTableName"
        echo "prev table name: $previousTableName"

        If ($thisTableName -ne $previousTableName) {  # there are up to four references to Table: **      
            
            If($previousTableName -ne '') {
                $xmlWriter.WriteFullEndElement()  # TABLE  
                echo "Close table name: $previousTableName"    
            }

            $xmlWriter.WriteStartElement("TABLE")
            echo "Write table name: $thisTableName"

            $xmlWriter.WriteAttributeString("TableName", $thisTableName)

            $previousTableName = $thisTableName
       } 

    } # table start

     If ($_ -match $fieldName) {
            
            echo "$_"
            $envVarArr = $_.split(":")
            $thisFieldName = $envVarArr[1].Trim()

            If ($thisFieldName -ne $previousFieldName) {

                    <#If ($previousFieldName -ne '') {
                        #$xmlWriter.WriteFullEndElement() # FIELD
                        $fieldFlagOn = $false
                    }#>
                    #$xmlWriter.WriteStartElement("FIELD")
                    #$xmlWriter.WriteAttributeString("FieldName",$thisFieldName)

                $fieldFlagOn = $true
                $previousFieldName = $thisFieldName

            }
     }

     If ($_ -match $fieldNameDescription -and $fieldFlagOn -eq $true) {
            echo "$_"
            $xmlWriter.WriteStartElement("FIELD")
            $xmlWriter.WriteAttributeString("FieldName",$thisFieldName)
            
            $xmlWriter.WriteStartElement("DESC")

            $envVarArr = $_.split(":")

            $xmlWriter.WriteAttributeString("FieldDesc",$envVarArr[1].Trim())    

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement() # this
            $xmlWriter.WriteFullEndElement() # FIELD
            $fieldFlagOn = $false

     }

     If ($_ -match $fieldNameDescription -and $fieldFlagOn -eq $false) {
            echo "$_"

            #$xmlWriter.WriteAttributeString("TableDesc",$envVarArr[1].Trim())    

     }

     If ($_ -match $fieldNameHelp -and $fieldFlagOn -eq $true) {
            echo "$_"
            $xmlWriter.WriteStartElement("FIELD")
            $xmlWriter.WriteAttributeString("FieldName",$thisFieldName)

            $xmlWriter.WriteStartElement("DESC")

            $envVarArr = $_.split(":")

            $xmlWriter.WriteAttributeString("FieldDesc",$envVarArr[1].Trim())    

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement() # this
            $xmlWriter.WriteFullEndElement() # FIELD
            $fieldFlagOn = $false

     }


} # For Each

# Write the Document
# Write Close Tag for Root Element

$xmlWriter.WriteFullEndElement() # <-- Last TABLE
$xmlWriter.WriteFullEndElement() # <-- Closing RootElement

# End the XML Document

$xmlWriter.WriteEndDocument() 

# Finish The Document

$xmlWriter.Finalize

$xmlWriter.Flush

$xmlWriter.Close()