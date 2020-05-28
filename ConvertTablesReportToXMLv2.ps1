# Script to read a SolCase DMP file and format it's contents into XML output

# set the input file path

$inFile = 'C:\Users\kieran.caulfield\Birkett Long LLP\IT Team - Documents\IT Share\Transformation\Data Modelling\DBTablesReport_SOS'

# set the file path for the output

$outFile = "C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Spool\XML\SolCaseTablesReport_SOS.xml"

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

$tableFlagOn = $false
$fieldFlagOn = $false
$indexFlagOn = $false
$indexGroupFlagOn = $false

$indexName = ''
$indexField = ''

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

$fieldSummaryStart = "(FIELD SUMMARY\W)"
$fieldOrderStart = "^(?=.*Order)(?=.*Field)(?=.*Name).*$"
$fieldFormatStart = "(^Field Name\s*Format\b)"
$fieldSummaryDashes = "(^----)"
$startsWithANumber = "([0-9]+) .*"

$indexStart = "^(?=.*Flags)(?=.*Index)(?=.*Name).*$"
$indexEnd = "(Index Name:\W)"
$indexLine = "(-INDEX\W)"
#$primaryIndex = "(^p.*-INDEX\W)"
#$primaryIndex = "(^[a-z].*[A-Z]-[A-Z]*\W)"
$primaryIndex = "(^[a-z].*[A-Z]*\+)"
$primaryIndexP = "(^[p].*[A-Z]-[A-Z]*\W)"
$primaryUniqueIndex = "(^pu.*-INDEX\W)"

#$indexNameSearch = "(.[A-Z]*.[A-Z]*.[A-Z]*-INDEX\W)"
$indexNameSearch = "(.[A-Z]*.[A-Z]*.[A-Z]*-INDEX\W)|(.[A-Z]*.[A-Z]*.[A-Z]*-IDX\W)|(^[a-z].*[A-Z]-[A-Z]*\W)|(^[a-z].*[A-Z]*\+)|(.[A-Z].*[0-9]*\+)"
$indexFieldSearch = "(\+\s[a-zA-Z0-9-]*$)|(\+\s[a-zA-Z0-9_]*$)"

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
                $tableFlagOn = $false  
            }

            $xmlWriter.WriteStartElement("TABLE")
            echo "Write table name: $thisTableName"
            $tableFlagOn = $true

            $xmlWriter.WriteAttributeString("TableName", $thisTableName)

            $previousTableName = $thisTableName

            $xmlWriter.WriteStartElement("FIELDS")
       } 

    } # table start

    <#If ($_ -match $fieldNameDescription -and $tableFlagOn -eq $true) {
        # this is a table description, only do this once
        $tableDesc = $matches[0].Trim()
        $xmlWriter.WriteAttributeString("TableDescription", $tableDesc)
        $tableFlagOn = $false

    }#>

     #Order Field Name                       Data Type   Flags
     #----- -------------------------------- ----------- -----    
     If ($_ -match $fieldOrderStart) {
            $fieldFlagOn = $true
     }

     #Field Name                       Format
     #-------------------------------- -----------------------------
     If ($_ -match $fieldFormatStart) {
            $fieldFlagOn = $false
     }

     If ($_ -match $startsWithANumber -and $fieldFlagOn -eq $true) {
            
            echo "$_"
            $envVarArr = $_.Split(' ').Where({$_.Trim() -ne ''})
            $thisFieldName = $envVarArr[1].Trim()

            $xmlWriter.WriteStartElement("FIELD")
            $xmlWriter.WriteAttributeString("FieldName",$thisFieldName)
            $xmlWriter.WriteAttributeString("Position",$envVarArr[0].Trim())
            $xmlWriter.WriteAttributeString("DataType",$envVarArr[2].Trim())
            #$xmlWriter.WriteAttributeString("Flag",$envVarArr[3].Trim())
            $xmlWriter.WriteFullEndElement() # FIELD
     } # Field Name

     #Flags Index Name                       Cnt Field Name
     #----- -------------------------------- --- ---------------------------------  
     If ($_ -match $indexStart) {
            # close the FIELDS Nodeset
            echo "Index Group Starting"
            $xmlWriter.WriteFullEndElement() # FIELDS
            $indexGroupFlagOn = $true
     }

     #      AMATDB-LEVEL-FEE-INDEX             2 + IMPLEMENTATION
     If ($_ -match $indexNameSearch -and $indexGroupFlagOn -eq $true) {
            echo "Index Name Found"
            echo "$_"
            $indexFlagOn = $true

            # get the actual index name 
            if ($_ -match $indexNameSearch) {
                $indexName = $matches[0].Trim("+"," ")
                $indexName = $indexName -replace " [0-9]",""
                $indexName = $indexName.Trim()
            }

            if ($_ -match $primaryIndex) {
                # get the first full word
                $indexName = $matches[0].Trim()

                $indexName = $indexName.Substring(6)
                $indexName = $indexName.Substring(0,$indexName.IndexOf(" "))
            }

            echo $indexName

            $xmlWriter.WriteStartElement("INDEX")
            $xmlWriter.WriteAttributeString("IndexName",$indexName.TrimStart("+ "))

            if ($_ -match $indexFieldSearch) {
                $indexField = $matches[0].Trim()          
                # Add the first actual Index Value
                $xmlWriter.WriteStartElement("FIELD")
                    $xmlWriter.WriteAttributeString("IndexFieldName",$indexField.TrimStart("+ "))
                $xmlWriter.WriteFullEndElement() # FIELD

                ## what type of index?
                If ($_ -match $primaryIndex) {
                    If ($_ -match $primaryIndexP) {
                        $xmlWriter.WriteStartElement("INDEX-TYPE")
                            $xmlWriter.WriteAttributeString("IndexType","primary")
                        $xmlWriter.WriteFullEndElement() # INDEX TYPE
                    }
                }

            }

            #$xmlWriter.WriteFullEndElement() # INDEX
            # end loop, next record
            return
     }

     If ($indexGroupFlagOn -eq $true -and $_ -match $indexEnd) {
        #End of Indexes DEFN
        $indexFlagOn = $false
        $indexGroupFlagOn = $false
     }

     If ($indexFlagOn -eq $true -and $_.length -eq 0) {
        #End of this Index DEFN
        $indexFlagOn = $false
        $xmlWriter.WriteFullEndElement() # INDEX
     }

     If ($indexFlagOn -eq $true -and $_ -match $indexFieldSearch) {

        echo "$_"
        # We are on the next field of the index.
         $indexField = $matches[0].Trim()          
         # Add the first actual Index Value
            $xmlWriter.WriteStartElement("FIELD")
                $xmlWriter.WriteAttributeString("IndexFieldName",$indexField.TrimStart("+ "))
            $xmlWriter.WriteFullEndElement() # FIELD

            # end loop, next record
            # return  always keep this last!
     }


     <#If ($_ -match $indexLine -and $indexFlagOn -eq $true) {
            
            echo "$_"
            # get the actual index name 
            if ($_ -match $indexNameSearch) {
                $indexName = $matches[0].Trim()
            }

            echo $indexName

            $xmlWriter.WriteStartElement("INDEX")
            $xmlWriter.WriteAttributeString("IndexName",$indexName.Trim())

            if ($_ -match $indexFieldSearch) {
                $indexField = $matches[0].Trim()          
                # Add the first actual Index Value
                $xmlWriter.WriteStartElement("FIELD")
                    $xmlWriter.WriteAttributeString("IndexFieldName",$indexField.TrimStart("+ "))
                $xmlWriter.WriteFullEndElement() # FIELD
            }

            $xmlWriter.WriteFullEndElement() # INDEX
     } # Index Defn#>

     <#if ($_ -match $indexFieldSearch -and $indexFlagOn -eq $true) {
            $indexField = $matches[0].Trim()          
            # Add the next actual Index Value
            $xmlWriter.WriteStartElement("FIELD")
                $xmlWriter.WriteAttributeString("IndexFieldName",$indexField.TrimStart("+ "))
            $xmlWriter.WriteFullEndElement() # FIELD
     }#>


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