xquery version "3.1";

import module namespace csQb="https://correspsearch.net/api/query-builder" at "modules/csQuerybuilder.xqm";

declare namespace fn="http://www.w3.org/2005/xpath-functions";

declare function local:gefx($jsonxml) {
    <gexf xmlns="http://gexf.net/1.3" version="1.3">
        <meta lastmodifieddate="{current-dateTime()}">
            <creator>correspSearch.net API 2.0</creator>
            <description></description>
        </meta>
        <graph mode="static" defaultedgetype="directed">
            <nodes>
                {local:nodes($jsonxml)}
            </nodes>
            <edges>
                {local:letters($jsonxml)}
            </edges>
        </graph>
    </gexf>
};

declare function local:nodes($jsonxml) {
let $distinct-correspondents := distinct-values($jsonxml//fn:array[@key='names']/fn:map/fn:string[@key='canonical_ref']/text())
return
    for $id in $distinct-correspondents
    let $name := ($jsonxml//fn:map[fn:string[@key='canonical_ref']=$id])[1]/fn:string[@key='canonical_name']/text()
    return
    <node xmlns="http://gexf.net/1.3" id="{$id}" label="{$name}" />
};

declare function local:letters($jsonxml) {
    for $letter in $jsonxml//fn:array[@key='hits']/fn:map
    let $id := $letter//fn:string[@key='_id']/text()
    let $source := $letter//fn:array[@key='names']/fn:map[fn:string[@key='action']='sent']/fn:string[@key='canonical_ref']/text()
    let $target := $letter//fn:array[@key='names']/fn:map[fn:string[@key='action']='received']/fn:string[@key='canonical_ref']/text()
    return
    if ($source and $target)
    then <edge xmlns="http://gexf.net/1.3" id="{$id}" source="{$source}" target="{$target}" />
    else ()
};

(:declare function local:edges($letters, $nodes) {
    for $node in $nodes
    let $id := $node/@id
    let $targets := distinct-values($letters[@source=$id]/@target)
    let $sources := distinct-values($letters[@target=$id]/@sources)
        return
            for $letter in $sources 
            return
            ()
};:)

declare function local:request($page as xs:int) {
let $query := csQb:build-query(false(), 12000, $page)
let $request :=
    hc:send-request(
        <hc:request 
        method="POST"
        href="">
            <hc:header name="Content-Type" value="application/json"/>
            <hc:body method="text" media-type="application/json">
                {$query}
            </hc:body>
        </hc:request>)

let $response := util:base64-decode($request[2])

let $xml := json-to-xml($response)
return
$xml
};

(:declare function local:requests() {
    let $first-request := local:request(xs:int(1))
    let $total-amount := xs:int($first-request//fn:map[@key='total']/fn:number[@key='value']/text())
    let $max := ceiling($total-amount div 100)
    let $requests := 
        for $page in 1 to xs:int($max)
        let $request := local:request($page)
        return
        xmldb:store('/db/apps/csAPI/api/v2.0/cache/gexf/', xs:string($page)||'.xml', $request)
    return    
    ()
};:)

declare function local:create-gexf() {
    local:gefx(collection('/db/apps/csAPI/api/v2.0/cache/gexf/')/fn:map)
};

xmldb:store('/db/apps/csAPI/api/v2.0/cache', 'test-2.gexf', local:gefx(local:request(1)))