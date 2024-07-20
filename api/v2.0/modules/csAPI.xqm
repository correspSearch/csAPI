xquery version "3.1";

module namespace csAPI="https://correspseaech.net/api/2.0/csAPI";

import module namespace es2cmif="https://correspsearch.net/api/es2cmif" at "es2cmif.xqm";
import module namespace csQb="https://correspsearch.net/api/query-builder" at "csQuerybuilder.xqm";

declare variable $csAPI:harvester-data := '/db/apps/csHarvester/data/';
declare variable $csAPI:query-string := csQb:build-query();
declare variable $csAPI:debug := 
    if (request:get-parameter('debug', ())='yes') 
    then true()
    else false()
;

declare function csAPI:substring-afterlast($string as xs:string, $cut as xs:string){
  if (matches($string, $cut))
    then csAPI:substring-afterlast(substring-after($string,$cut),$cut)
  else $string
};

declare function csAPI:get-data() {
let $request :=
    hc:send-request(
        <hc:request 
        method="POST"
        href="">
            <hc:header name="Content-Type" value="application/json"/>
            <hc:body method="text" media-type="application/json">
                {$csAPI:query-string}
            </hc:body>
        </hc:request>)

let $response := util:base64-decode($request[2])

let $xml := json-to-xml($response)

return
$xml
};

declare function csAPI:cmif() {
    if ($csAPI:debug)
    then csAPI:get-data()
    else es2cmif:create-cmif(csAPI:get-data())
};

declare function csAPI:csv($flavor as xs:string) {
let $xslt :=
    if ($flavor='pdb18')
    then 'csv-pdb18.xsl'
    else 'csv.xsl'
return    
    transform:transform(csAPI:cmif(), doc('../xslt/'||$xslt), ())
};

declare function csAPI:csv() {
    csAPI:csv('default')
};