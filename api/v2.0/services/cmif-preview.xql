xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html media-type=text/html";

let $url := request:get-parameter('url', ())

let $xml-data := 
    if (request:get-parameter('xml-file', ()))
    then request:get-uploaded-file-data('xml-file') 
    else if ($url)
    then doc($url)
    else ()
    
let $xml :=
    if (request:get-parameter('xml-file', ()))
    then parse-xml(util:base64-decode($xml-data))
    else $xml-data
    

return
transform:transform($xml, doc('cmif-preview.xsl'), ())
