# List details of all files in import list , UNC paths
$fileIn = "C:\Users\kieran.caulfield\Documents\Development\V3PR-SOS Query.csv"
$dirOut = "C:\Users\kieran.caulfield\Documents\V3PR-FileDump"


$data = Import-Csv -Header MTCODE,CLCODE,OATH,NAME,DESC,FULLNAME,DATEOPEN,DOCREF $fileIn 

foreach($item in $data) 
{
    echo "$dirOut\$($item.MTCODE)-$($item.DOCREF)-$($item.NAME)"
    Copy-Item -Path $($item.FULLNAME) -Destination "$dirOut\$($item.MTCODE)-$($item.DOCREF)-$($item.NAME)" -Force
}
