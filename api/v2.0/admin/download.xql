xquery version "3.1";

import module namespace csAPI="https://correspseaech.net/api/2.0/csAPI" at "../modules/csAPI.xqm";
import module namespace es2cmif="https://correspsearch.net/api/es2cmif" at "../modules/es2cmif.xqm";
import module namespace csQb="https://correspsearch.net/api/query-builder" at "../modules/csQuerybuilder.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $local:download-dir := '';
declare variable $local:size := 10000;

declare function local:cleanFileName($url as xs:string) as xs:string {
    let $replace1 := replace($url, 'http://', '')
    let $replace2 := replace($replace1, 'https://', '')
    let $replace3 := replace($replace2, '/', '_')
    let $replace4 := replace($replace3, ':', '_')
    let $replace5 := replace($replace4, '.xql', '')
    let $replace6 := replace($replace5, '.xml', '')
    let $replace7 := replace($replace6, 'ä', 'ae')
    let $replace8 := replace($replace7, 'ü', 'ue')
    let $replace9 := replace($replace8, 'ö', 'oe')
    let $replace10 := replace($replace9, '–', '-')
    let $replace11 := replace($replace10, '\?', '_')
    let $replace12 := replace($replace11, '#', '_')
    return
    $replace12
};

declare function local:get-data($cmif-url, $page) {
let $request :=
    hc:send-request(
        <hc:request 
        method="POST"
        href="">
            <hc:header name="Content-Type" value="application/json"/>
            <hc:body method="text" media-type="application/json">
                {csQb:build-query(false(), $local:size, $page, $cmif-url)}
            </hc:body>
        </hc:request>)

let $response := util:base64-decode($request[2])

let $xml := json-to-xml($response)

return
$xml
};

declare function local:download($cmif-url as xs:string, $page as xs:int) {
    let $esxml := local:get-data($cmif-url, $page)
    let $total := xs:int($esxml//fn:map[@key='total']/fn:number/text())
    let $page-max := ceiling($total div $local:size)
    let $serialize-params := 
        <output:serialization-parameters>
            <output:method value="xml"/>
            <output:omit-xml-declaration value="yes"/>
            <output:indent value="no"/>
         </output:serialization-parameters>
    let $path := 
        if ($page-max > 1)
        then $local:download-dir||local:cleanFileName($cmif-url)||'_'||$page||'.xml' 
        else $local:download-dir||local:cleanFileName($cmif-url)||'.xml' 
    let $cmif-file := es2cmif:create-cmif($esxml)
    let $store := file:serialize($cmif-file, $path, $serialize-params)
    return
        if ($page-max > 1 and $page!=$page-max)
        then (util:wait(5000), local:download($cmif-url, $page+1))
        else ()    
};

(:https://correspsearch.net/storage/dedekind-weber.xml :)
(:https://weber-gesamtausgabe.de/cmif_v2.xml:)

(file:delete($local:download-dir),
file:mkdir($local:download-dir),
for $cmif-file in collection('/db/apps/csHarvester/data/cmif-files')//tei:TEI
let $cmif-url := normalize-space($cmif-file//tei:publicationStmt/tei:idno[@type="url"]/text())
return
local:download($cmif-url, 1))
