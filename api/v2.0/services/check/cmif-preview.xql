xquery version "3.0";

import module namespace schxslt = "https://doi.org/10.5281/zenodo.1495494";
import module namespace cs-check="https://correspsearch.net/services/check/geonames" at "check-geonames.xql";

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


let $checks :=
    element check { 
    validation:jing-report($xml, doc('cmi-customization.rng')),
    schxslt:validate($xml, doc('cmif.sch')),
    cs-check:geonames($xml)
    } 

return
transform:transform(($xml, $checks), doc('view.xsl'), ())

