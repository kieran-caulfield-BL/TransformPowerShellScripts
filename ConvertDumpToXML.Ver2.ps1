# Script to read a SolCase DMP file and format it's contents into XML output

# set the input file path

$inFile = 'C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\DumpFiles\V3PR.DMP'

# set the file path for the output

$outFile = "C:\Users\kieran.caulfield\OneDrive - Birkett Long LLP\Documents\Spool\XML\V3PR_DumpFileFormatted.xml"

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

$xmlWriter.WriteStartElement("SOLCASE")

#initialise node group flags

$closeNodeGroup = $false
$matterDefn = $false
$agendaDefn = $false
$screenDefn = $false
$reportDefn = $false
$fieldFlagOn = $false

# unique id needed for sorting in xslt
$leValue = "0"
$neValue = "0"
$seValue = "0"
$uniqueID = "0-0"

# screed id
$screenName = ""

$countOfIN = 0
$countOfSS = 0
$countOfRE = 0

$thisMatterType = ""

$patternPipe = [RegEx]::Escape("|")

# Open the dump file

$data = Get-Content $inFile 

$data | ForEach-Object {

    #$envVarArr = $_.ToString().Split('","')
    #$envVarArr = $_.split(",")
    $envVarArr = $_ -split ',(?=(?:[^"]|"[^"]*")*$)' 


    If ($envVarArr[0] -eq '"CREATE"') {
        If ($envVarArr[1] -eq '"MATTYPE"') {
            $matterDefn = $true    
            If([string]::IsNullOrWhiteSpace($envVarArr[2])) { 
                $thisMatterType = $envVarArr[2]  
                } Else {
                    $thisMatterType = $envVarArr[2].Trim('"')  
                }   
         } Else {
            $matterDefn = $false
         }
        If ($envVarArr[1] -eq '"AGENDA"') {
            $agendaDefn = $true       
         } Else {
            $agendaDefn = $false
         }
        If ($envVarArr[1] -eq '"SCREEN"') {
            $screenDefn = $true 
            If([string]::IsNullOrWhiteSpace($envVarArr[2])) { 
                $screenName = $envVarArr[2]  
                } Else {
                    $screenName = $envVarArr[2].Trim('"')  
                }
         } Else {
            $screenDefn = $false
         }
       If ($envVarArr[1] -eq '"REPORT"' -or $envVarArr[1] -eq '"REPDETAIL"') {
            $reportDefn = $true
            if($envVarArr[1] -eq '"REPORT"'){
                $countOfRE = 0
            }       
         } Else {
            $reportDefn = $false
         }
    }

    If ($envVarArr[0] -eq '"DS"' -and $matterDefn -eq $true) {

        If ($closeNodeGroup -eq $true) {

            $xmlWriter.WriteEndElement()  # MATTER
            $closeNodeGroup = $false
        }

            Write-Output 'MATTER ' $envVarArr[0] $envVarArr[1]

            $xmlWriter.WriteStartElement("MATTER_TYPE")

            $xmlWriter.WriteAttributeString($envVarArr[0].Trim('"'), $envVarArr[1].Trim('"'))
            $xmlWriter.WriteAttributeString("MATTER", $thisMatterType)

            $closeNodeGroup = $true       

     }

     If ($envVarArr[0] -eq '"SS"' -and $matterDefn -eq $true) {

            # This is a script segment

            $countOfSS = $countOfSS + 1

            $xmlWriter.WriteStartElement("SS")
            $xmlWriter.WriteAttributeString("SS_NUMBER",$countOfSS) 


            $CDataFormatted = $envVarArr[1].Trim('"')
            # get rid of SOH unprintable characters
            $CDataFormatted = $CDataFormatted -replace '\u0001', ''
            # only print stuff to the right of  the word "Non"
            $CDataFormatted = $CDataFormatted.Substring($CDataFormatted.IndexOf("Non")+3)
            $xmlWriter.WriteCData($CDataFormatted)

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # SS

     }


    If ($envVarArr[0] -eq '"AT"' -and $agendaDefn -eq $true) {

        If ($closeNodeGroup -eq $true) {

            # create uniqueId Node

            $uniqueID = "$leValue-$neValue-$seValue"
            Write-Output $uniqueID
                $xmlWriter.WriteStartElement("ID")
                $xmlWriter.WriteAttributeString("IDENTIFIER",$uniqueID)    
                $xmlWriter.WriteEndElement()  # ID
            $leValue = "0"
            $neValue = "0"
            $seValue = "0"
            $countOfIN = 0
            $countOfSS = 0

            $xmlWriter.WriteEndElement()  # AGENDA
            $closeNodeGroup = $false
        }

            Write-Output 'AGENDA ' $envVarArr[0] $envVarArr[1]

            $xmlWriter.WriteStartElement("AGENDA")

            $xmlWriter.WriteAttributeString($envVarArr[0].Trim('"'), $envVarArr[1].Trim('"'))
            $xmlWriter.WriteAttributeString("MATTER", $thisMatterType)

            $closeNodeGroup = $true       

     }

     If ($envVarArr[0] -eq '"DE"' -and $agendaDefn -eq $true) {

            # This is 2nd line of definition

            $xmlWriter.WriteStartElement("DE")

            $xmlWriter.WriteAttributeString("DESCRIPTION",$envVarArr[1].Trim('"'))    

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # DESC

     }

     If ($envVarArr[0] -eq '"DO"' -and $agendaDefn -eq $true) {

            # This is 2nd line of definition

            $xmlWriter.WriteStartElement("DO")

            $xmlWriter.WriteAttributeString("DOCUMENT",$envVarArr[1].Trim('"'))    

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # DO

     }

     # IN Instructions is CDATA mix of prompts and Scripts text. Depending on the TY value.

     If ($envVarArr[0] -eq '"IN"' -and $agendaDefn -eq $true) {

            $countOfIN = $countOfIN + 1

            $xmlWriter.WriteStartElement("IN")
            $xmlWriter.WriteAttributeString("IN_NUMBER",$countOfIN) 


            $CDataFormatted = $envVarArr[1].Trim('"')
            # get rid of SOH unprintable characters
            $CDataFormatted = $CDataFormatted -replace '\u0001', ''
            #$CDataFormatted = $CDataFormatted -replace '\|-\|', '"'
            #$CDataFormatted = $CDataFormatted -replace '\|=\|', '\&#xD;'
            $CDataFormatted = $CDataFormatted.Substring($CDataFormatted.IndexOf("Non")+3)
            $xmlWriter.WriteCData($CDataFormatted)
            #$xmlWriter.CreateTextNode($CDataFormatted)
            #$xmlWriter.WriteString($CDataFormatted)

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # IN

     }

     If ($envVarArr[0] -eq '"SS"' -and $agendaDefn -eq $true) {

            # This is a script segment

            $countOfSS = $countOfSS + 1

            $xmlWriter.WriteStartElement("SS")
            $xmlWriter.WriteAttributeString("SS_NUMBER",$countOfSS) 


            $CDataFormatted = $envVarArr[1].Trim('"')
            # get rid of SOH unprintable characters
            $CDataFormatted = $CDataFormatted -replace '\u0001', ''
            #$CDataFormatted = $CDataFormatted -replace '\|-\|', '"'
            #$CDataFormatted = $CDataFormatted -replace '\|=\|', '\&#xD;'
            # only print stuff to the right of  the word "Non"
            $CDataFormatted = $CDataFormatted.Substring($CDataFormatted.IndexOf("Non")+3)
            $xmlWriter.WriteCData($CDataFormatted)

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # SS

     }

     If ($envVarArr[0] -eq '"LE"' -and $agendaDefn -eq $true) {

            # This is 2nd line of definition

            $xmlWriter.WriteStartElement("LE")

            $xmlWriter.WriteAttributeString("LINKED",$envVarArr[1].Trim('"'))  
            $leValue = $envVarArr[1].Trim('"')

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # LE

     }

     If ($envVarArr[0] -eq '"NE"' -and $agendaDefn -eq $true) {

            # This is 2nd line of definition

            $xmlWriter.WriteStartElement("NE")

            $xmlWriter.WriteAttributeString("PARENT_ID",$envVarArr[1].Trim('"')) 
            $neValue = $envVarArr[1].Trim('"')   

            # now close the NE XML Node Group

            $xmlWriter.WriteEndElement()  # NE

     }

     If ($envVarArr[0] -eq '"SE"' -and $agendaDefn -eq $true) {

            # This is 2nd line of definition

            $xmlWriter.WriteStartElement("SE")

            $xmlWriter.WriteAttributeString("POSN_ID",$envVarArr[1].Trim('"')) 
            $seValue = $envVarArr[1].Trim('"')   

            # now close the SE XML Node Group

            $xmlWriter.WriteEndElement()  # SE

     }

     If ($envVarArr[0] -eq '"TY"' -and $agendaDefn -eq $true) {

            # This is 2nd line of definition

            $xmlWriter.WriteStartElement("TY")

            $xmlWriter.WriteAttributeString("TYPE",$envVarArr[1].Trim('"'))    

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # TY

     }

     If ($envVarArr[0] -eq '"DS"' -and $screenDefn -eq $true) {

        If ($closeNodeGroup -eq $true) {

            $xmlWriter.WriteEndElement()  # SCREEN
            $closeNodeGroup = $false
        }

            Write-Output 'SCREEN ' $envVarArr[0] $envVarArr[1]

            $xmlWriter.WriteStartElement("SCREEN")

            $xmlWriter.WriteAttributeString($envVarArr[0].Trim('"'), $envVarArr[1].Trim('"'))
            $xmlWriter.WriteAttributeString("SCREEN-NAME", $screenName)
            $xmlWriter.WriteAttributeString("MATTER", $thisMatterType)

            $closeNodeGroup = $true       

     }
     
     If ($envVarArr[0] -eq '"FD"' -and $screenDefn -eq $true) {

            # description
            $fieldFlagOn = $true
            $xmlWriter.WriteStartElement("FIELDS")

            $xmlWriter.WriteStartElement("FD")

            $xmlWriter.WriteAttributeString("FIELD",$envVarArr[1].Trim('"'))    

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # FD

     }

     If ($envVarArr[0] -eq '"FH"' -and $screenDefn -eq $true) {

            # description

            $xmlWriter.WriteStartElement("FH")

            $xmlWriter.WriteAttributeString("HELPER",$envVarArr[1].Trim('"'))    

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # FH

     }

     If ($envVarArr[0] -eq '"FO"' -and $screenDefn -eq $true) {

            # Object

            $xmlWriter.WriteStartElement("FO")

            $objectCode = $envVarArr[1].Split(",")

            $xmlWriter.WriteAttributeString("CODE",$objectCode[0].Trim('"'))    

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # FO

     }

     If ($envVarArr[0] -eq '"FY"' -and $screenDefn -eq $true) {

            # Type, Lookup, Pointer etc

            $xmlWriter.WriteStartElement("FY")

            $xmlWriter.WriteAttributeString("TYPE",$envVarArr[1].Trim('"'))    

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # FY

            $xmlWriter.WriteFullEndElement() # FIELDS
            # assumes this is the last , there is always an FY at the end

     }

     If ($envVarArr[0] -eq '"DE"' -and $reportDefn -eq $true) {

        If ($closeNodeGroup -eq $true) {

            $xmlWriter.WriteEndElement()  # REPORT
            $closeNodeGroup = $false
        }

            Write-Output 'REPORT ' $envVarArr[0] $envVarArr[1]

            $xmlWriter.WriteStartElement("REPORT")

            $xmlWriter.WriteAttributeString($envVarArr[0].Trim('"'), $envVarArr[1].Trim('"'))
            $xmlWriter.WriteAttributeString("MATTER", $thisMatterType)

            $closeNodeGroup = $true       

     }

     If ($envVarArr[0] -eq '"RE"' -and $reportDefn -eq $true) {

            # This is a script segment

            $countOfRE = $countOfRE + 1

            $xmlWriter.WriteStartElement("RE")
            $xmlWriter.WriteAttributeString("RE_NUMBER",$countOfRE) 


            $CDataFormatted = $envVarArr[1].Trim('"')
            # get rid of SOH unprintable characters
            $CDataFormatted = $CDataFormatted -replace '\u0001', ''
            
            $xmlWriter.WriteCData($CDataFormatted)

            # now close the DESC XML Node Group

            $xmlWriter.WriteEndElement()  # RE

     }

} # For Each

# Write the Document
# Write Close Tag for Root Element

$uniqueID = "$leValue-$neValue-$seValue"
Write-Output $uniqueID
    $xmlWriter.WriteStartElement("ID")
    $xmlWriter.WriteAttributeString("IDENTIFIER",$uniqueID)    
    $xmlWriter.WriteEndElement()  # ID
$xmlWriter.WriteEndElement() # <-- Last AGENDA_TYPE
$xmlWriter.WriteEndElement() # <-- Closing RootElement

# End the XML Document

$xmlWriter.WriteEndDocument() 

# Finish The Document

$xmlWriter.Finalize

$xmlWriter.Flush

$xmlWriter.Close()