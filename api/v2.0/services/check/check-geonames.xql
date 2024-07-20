xquery version "3.0";

module namespace cs-check="https://correspsearch.net/services/check/geonames";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace gn="http://www.geonames.org/ontology#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare function cs-check:get-geonames-data($uri as xs:string) {
    if ($uri[matches(., 'geonames')])
    then
        let $rdf-uri := 'https://sws.geonames.org/'||substring-after($uri, 'org/')||'/about.rdf'
        return
        doc($rdf-uri)/*    
    else ()
};

declare function cs-check:geonames($tei-xml) as element() {

let $uris := distinct-values($tei-xml//tei:placeName/@ref/data(.))
let $count := count($uris)

let $data := 
    for $uri in $uris
    let $data := cs-check:get-geonames-data($uri)
    let $gn-class := substring-after($data//gn:featureClass/@rdf:resource, 'https://www.geonames.org/ontology#')
    let $gn-name := 
        if ($data//gn:officialName[@xml:lang='de'])
        then $data//gn:officialName[@xml:lang='de']/text()
        else if ($data//gn:alternateName[@xml:lang='de'])
        then $data//gn:alternateName[@xml:lang='de']/text()
        else $data//gn:name/text()
    let $tei-names := distinct-values($tei-xml//tei:placeName[@ref=$uri]/normalize-space())
    return
    element place {
        element uri { $uri },
        for $name in $tei-names
        return
        element tei-name { $name },
        for $name in $gn-name
        return
        element gn-name { $name },
        element gn-class { $gn-class }
    }
            
let $check := 
    for $place in $data
    let $check0 := matches($place/uri, 'https?://www.geonames\.org/\d+')
    let $check1 := $place/gn-name=$place/tei-name
    let $check2 := $place/gn-class='P'
    return
    if ($check1 and $check2)
    then ()
    else 
        element place {
           if ($check0) then () else element error { attribute type {'not-geonames'}, 'URI is not a valid GeoNames-URI' },
           if ($check1) then () else element error { attribute type {'name'}, 'Name in GeoNames does not match name in TEI source document' },
           if ($check2) then () else element error { attribute type {'class'}, 'GeoNames-ID has feature class other then "P (city, village etc.)"' },
           $place/*
       }

let $filtered-check :=
    for $place in $check
    return
    $place    

let $count-errors := count($filtered-check)

return
element geonames {
    element places { $count },
    element errors { $count-errors },
    $filtered-check
}
};