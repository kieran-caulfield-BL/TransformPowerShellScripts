# search the hist docs dump files for specific string values

#$searchValues = "BENJAMIN MARK GRIMMER PARMENTER|TIMOTHY OGLE|CLAIRE LOUISE ZITA READ|EMMA JOANNE CLARKE|CAROLINE DOWDING|BRUCE BALLARD|PHILIP WILLIAM GEORGE|KEITH LARKMAN|TONY FROST|PHILIP HODDELL|KURT GODDARD|DAVID WYBAR|ADRIAN LIVESLY|AMANDA SMALLCOMBE|SUSAN DIANE MASTERS|CHRISTOPHER HOLMES"
#$searchValues = "(\b[B].*PARMENTER\W)|(\b[B].*Parmenter\W)|(\b[T].*OGLE\W)|(\b[T].*Ogle\W)\|(\b[C].*READ\W)|(\b[C].*Read\W)|(\b[E].*CLARKE\W)|(\b[E].*Clarke\W)|(\b[C].*DOWDING\W)|(\b[C].*Dowding\W)|(\b[B].*BALLARD\W)|(\b[B].*Ballard\W)|(\b[P].*GEORGE\W)|(\b[K].*LARKMAN\W)|(\b[K].*Larkman\W)|(\b[T].*FROST\W)|(\b[T].*FROST\W)|(\b[P].*HODDELL\W)|(\b[P].*Hoddell\W)|(\b[K].*GODDARD\W)|(\b[K].*Goddard\W)|(\b[D].*WYBAR\W)|(\b[D].*WYybar\W)|(/b[A].*LIVESLEY\W)|(/b[A].*Livesley\W)|(\b[A].*SMALLCOMBE\W)|(\b[A].*Smallcombe\W)|(\b[S].*MASTERS\W)|(\b[S].*Masters\W)|(\b[C].*HOLMES\W)|(\b[C].*Holmes\W)"
#$searchValues = "(\b[B].*PARMENTER\W)|(\b[B].*Parmenter\W)|(\b[T].*OGLE\W)|(\b[T].*Ogle\W)\|(\b[C].*READ\W)|(\b[C].*Read\W)|(\b[E].*CLARKE\W)|(\b[E].*Clarke\W)"
#$searchValues = "(\b[B].*[A-Za-z] PARMENTER\W)|(\b[B].*[A-Za-z ]Parmenter\W)|(\b[T].*[A-Za-z ]OGLE\W)|(\b[T].*[A-Za-z ]Ogle\W)\|(\b[C].*[A-Za-z ]READ\W)|(\b[C].*[A-Za-z ]Read\W)|(\b[E].*[A-Za-z ]CLARKE\W)|(\b[E].*[A-Za-z ]Clarke\W)|(\b[C].*[A-Za-z ]DOWDING\W)|(\b[C].*[A-Za-z ]Dowding\W)|(\b[B].*[A-Za-z ]BALLARD\W)|(\b[B].*[A-Za-z ]Ballard\W)|(\b[P].*[A-Za-z ]GEORGE\W)|(\b[P].*[A-Za-z ]GeorgeE\W)|(\b[K].*[A-Za-z ]LARKMAN\W)|(\b[K].*[A-Za-z ]Larkman\W)|(\b[T].*[A-Za-z ]FROST\W)|(\b[T].*[A-Za-z ]Frost\W)|(\b[P].*[A-Za-z ]HODDELL\W)|(\b[P].*[A-Za-z ]Hoddell\W)|(\b[K].*[A-Za-z ]GODDARD\W)|(\b[K].*[A-Za-z ]Goddard\W)|(\b[D].*[A-Za-z ]WYBAR\W)|(\b[D].*[A-Za-z ]WYybar\W)|(/b[A].*[A-Za-z ]LIVESLEY\W)|(/b[A].*[A-Za-z ]Livesley\W)|(\b[A].*[A-Za-z ]SMALLCOMBE\W)|(\b[A].*[A-Za-z ]Smallcombe\W)|(\b[S].*[A-Za-z ]MASTERS\W)|(\b[S].*[A-Za-z ]Masters\W)|(\b[C].*[A-Za-z ]HOLMES\W)|(\b[C].*[A-Za-z ]Holmes\W)"
$searchValues = "(\b[B].*[A-Za-z] PARMENTER\W)|(\b[B].*[A-Za-z ]Parmenter\W)|(\b[T].*[A-Za-z ]OGLE\W)|(\b[T].*[A-Za-z ]Ogle\W)\|(\b[C].*[A-Za-z ]READ\W)|(\b[C].*[A-Za-z ]Read\W)|(\b[E].*[A-Za-z ]CLARKE\W)|(\b[E].*[A-Za-z ]Clarke\W)|(\b[C].*[A-Za-z ]DOWDING\W)|(\b[C].*[A-Za-z ]Dowding\W)|(\b[B].*[A-Za-z ]BALLARD\W)|(\b[B].*[A-Za-z ]Ballard\W)|(\b[P].*[A-Za-z ]GEORGE\W)|(\b[P].*[A-Za-z ]GeorgeE\W)|(\b[K].*[A-Za-z ]LARKMAN\W)|(\b[K].*[A-Za-z ]Larkman\W)|(\b[T].*[A-Za-z ]FROST\W)|(\b[T].*[A-Za-z ]Frost\W)|(\b[P].*[A-Za-z ]HODDELL\W)|(\b[P].*[A-Za-z ]Hoddell\W)|(\b[K].*[A-Za-z ]GODDARD\W)|(\b[K].*[A-Za-z ]Goddard\W)|(\b[D].*[A-Za-z ]WYBAR\W)|(\b[D].*[A-Za-z ]WYybar\W)|(/b[A].*[A-Za-z ]LIVESLEY\W)|(/b[A].*[A-Za-z ]Livesley\W)|(\b[A].*[A-Za-z ]SMALLCOMBE\W)|(\b[A].*[A-Za-z ]Smallcombe\W)|(\b[S].*[A-Za-z ]MASTERS\W)|(\b[S].*[A-Za-z ]Masters\W)|(\b[C].*[A-Za-z ]HOLMES\W)|(\b[C].*[A-Za-z ]Holmes\W)"

$inDir = 'C:\Users\kieran.caulfield\Documents\V3PR-FileDump\Converted'

$results = @()

Get-ChildItem $inDir -Filter "*.txt" |
    ForEach-Object {
        $currFile = $_
        echo "Reading: $currFile"
        # remove the -AllMatches flag from Select-String as we only want the first match (default)
        Get-Content $_.FullName | Select-String $searchValues | ForEach-Object {$_.Matches} | ForEach-Object {
                    echo "Processing Matches"
                    $results += New-Object PsObject -Property @{
                         #'FullName' = $currFile.FullName
                        'FileName' = $currFile.Name
                        'Shortname' = $currFile.Name.Substring($currFile.Name.Length - 16,12)
                        'MatterCode' = $currFile.Name.Substring(0,13)
                        'Match'= $_.Groups[0].Value
                    }
                }
  
    }

$results | Export-Csv "C:\Users\kieran.caulfield\Documents\Development\SearchResults.csv" -NoTypeInformation