xquery version "3.1";

import module namespace csAPI="https://correspseaech.net/api/2.0/csAPI" at "modules/csAPI.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

let $xml := transform:transform(csAPI:cmif(), doc('xslt/forceArray.xsl'), ())

let $json-string :=
serialize($xml,
     <output:serialization-parameters>
        <output:method value="json"/>
        <output:json-ignore-whitespace-text-nodes value="yes"/>
     </output:serialization-parameters>)

return
response:stream($json-string, 'media-type=application/json')