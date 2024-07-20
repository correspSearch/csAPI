xquery version "3.1";

import module namespace csAPI="https://correspseaech.net/api/2.0/csAPI" at "../modules/csAPI.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(: SD 2024-03-22: Hier muss diese ältere Serialisierungs-Methode verwendet werden und nicht serialize+response:strem(), 
weil sonst Ampersands als &amp; ausgegeben werden und nicht als korrekter Unicode-Point "&" :)
declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:cmif-url := request:get-parameter('url', ());

declare function local:index() {
element index {
    element about {
        'Index of all CMIF files harvested by correspSearch.net. You can retrieve each stored file by calling our API at https://correspsearch.net/api/v2.0/ingest/get.xql?url={url}'
    },
    for $doc in collection($csAPI:harvester-data||'/cmif-files')//tei:TEI
    return
        (: Durch JSON-Serialiserung wird dieser Name die Wurzel, nochmal checken bei Gelegenheit :)
        element index-cmif-files {
            element url { normalize-space($doc//tei:publicationStmt/tei:idno[@type='url']/text()) },
            element last-modified { xmldb:last-modified($csAPI:harvester-data||'/cmif-files', csAPI:substring-afterlast(base-uri($doc), '/')) }
        }
}        
};

declare function local:cmif($url as xs:string) {
    let $cmif-file := collection($csAPI:harvester-data||'/cmif-files')//tei:TEI[.//tei:idno[@type='url']=$url]
    return
    if ($cmif-file)
    then transform:transform($cmif-file, doc('forceArray.xsl'), ())
    else <error>CMIF file not found</error>
};

if ($local:cmif-url)
then local:cmif($local:cmif-url)
else local:index()