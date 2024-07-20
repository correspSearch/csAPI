xquery version "3.0";

declare option exist:serialize "media-type=application/json";

let $q := encode-for-uri(request:get-parameter('q', ()))
let $id := encode-for-uri(request:get-parameter('id', ()))
let $fc := encode-for-uri(request:get-parameter('fc', 'P'))

let $url := if ($q!='')
    then 'http://api.geonames.org/searchJSON?q='||$q||'&amp;featureClass='||$fc||'&amp;maxRows=10&amp;username='
    else if ($id != '') 
    then 'http://api.geonames.org/getJSON?geonameId='||$id||'&amp;username='
    else ()

let $json :=
    if ($q!='' or $id != '')
    then util:base64-decode(hc:send-request(<hc:request method="GET" href="{$url}"></hc:request>)[2])
    else ()    

return
$json
