xquery version "3.1";

module namespace csBeacon="https://correspseaech.net/api/2.0/csAPI/Beacon";

declare namespace fn = "http://www.w3.org/2005/xpath-functions";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare variable $csBeacon:beacon-cache := '/db/apps/csAPI/api/v2.0/cache/beacon/';

declare variable $csBeacon:authorities := 
    map {
        "gnd" : 'http://d-nb.info/gnd/',
        "viaf" : 'http://viaf.org/viaf/',
        "lc" : 'http://lccn.loc.gov/',
        "bnf" : 'http://catalogue.bnf.fr/ark:/12148/',
        "ndl" : 'http://id.ndl.go.jp/auth/ndlna/'
    };

declare function local:query($offset as xs:string) {

let $offset :=
    if ($offset)
    then xs:int($offset) * 1000
    else '0'

let $query :=
    map {
	"from": $offset,
	"size": 1000,
	"track_total_hits": 30000,
	"query": map {
		"simple_query_string": map {
			"query": "*",
			"fields": [
				"text"
			],
			"default_operator": "and"
		}
	}
}

let $serialize-params := 
    <output:serialization-parameters>
        <output:method value="json"/>
        <output:json-ignore-whitespace-text-nodes value="yes"/>
        <output:allow-duplicate-names value="yes" />
     </output:serialization-parameters>

return
serialize($query, $serialize-params)
};

declare function local:request($offset as xs:string) {
let $request :=
    hc:send-request(
        <hc:request 
        method="POST"
        href="">
            <hc:header name="Content-Type" value="application/json"/>
            <hc:body method="text" media-type="application/json">
                {local:query($offset)}
            </hc:body>
        </hc:request>)

let $response := util:base64-decode($request[2])

let $xml := json-to-xml($response)

return
$xml
};

declare function local:create-entry($entry) {
    let $name_type := $entry/fn:string[@key="name_type"]/text()
    let $name := $entry/fn:string[@key="canonical_name"]/text()
    let $birth := $entry/fn:string[@key="birth_date"]/text()
    let $death := $entry/fn:string[@key="death_date"]/text()
    let $gender := $entry/fn:string[@key="gender"]/text()
    let $canonical_ref := $entry/fn:string[@key="canonical_ref"]/text()
    let $id-attributes :=
        for $authority in map:keys($csBeacon:authorities)
        let $uris := $entry/fn:array[@key="ref"]/fn:string[matches(., $csBeacon:authorities($authority))]/text()
        return
            if ($uris)
            then
                attribute 
                    { $authority } 
                    { for $uri at $pos in $uris
                      let $id := substring-after($uri, $csBeacon:authorities($authority))
                      return
                      if ($pos=1)
                      then $id   
                      else ' '||$id
                     } 
            else ()
    return
    element { $name_type } {
        attribute canonical_ref { $canonical_ref },
        $id-attributes,
        attribute gender { $gender },
        if ($name_type='persName')
        then $name||', '||$birth||'-'||$death
        else $name
    }
};

declare function csBeacon:create-cache() {
    for $n in 0 to 20
    let $data := local:request($n)
    let $entries :=
        element root {
        for $entry in $data//fn:array[@key="hits"]/fn:map/fn:map[@key="_source"]
        return
        local:create-entry($entry)
        }
    return
        xmldb:store($csBeacon:beacon-cache, xs:string($n)||'.xml', $entries)
};

declare function csBeacon:get-beacon($authority as xs:string) {

let $check :=
    if ($csBeacon:authorities($authority))
    then true()
    else false()
    
let $IDs :=
    if ($check)
    then
        for $authority-attr in util:eval('collection($csBeacon:beacon-cache)//@'||$authority)
        return
            for $id in tokenize($authority-attr, ' ')
            return
            (: wegen zwei "Irrläufern" im Index :)
            if (matches($id, 'http'))
            then ()
            else $id
    else ()

let $IDsWithLinebreaks :=
    for $x in $IDs
    return
    if ($x!='')
    then (concat($x, '&#xa;'))
    else ()

let $count := count($IDs)

let $metadata := 
<p>
#FORMAT: Beacon
#PREFIX: {$csBeacon:authorities($authority)}
{if ($authority='gnd') 
then 
'&#xa;#TARGET: https://correspsearch.net/de/suche.html?s='||$csBeacon:authorities($authority)||'{ID}'
else 
'&#xa;#TARGET: https://correspsearch.net/en/search.html?s='||$csBeacon:authorities($authority)||'{ID}'}
#FEED: https://correspsearch.net/api/v2.0/beacon.xql
#CONTACT: correspsearch@bbaw.de
#INSTITUTION: Berlin-Brandenburgische Akademie der Wissenschaften
#NAME: correspSearch
#DESCRIPTION: {$count} Korrespondenten (Personen und Institutionen) mit URI aus dem Namensraum {$csBeacon:authorities($authority)}, von denen Briefe und Gegenbriefe in correspSearch gefunden wurden 
#TIMESTAMP: {xmldb:last-modified($csBeacon:beacon-cache, '0.xml')} &#xa;
</p>
    
return
if ($check)
then
    ($metadata, 
    $IDsWithLinebreaks)
else 
    'ERROR: Authority file not supported'

};
