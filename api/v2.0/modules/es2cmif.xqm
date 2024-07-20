xquery version "3.1";

module namespace es2cmif="https://correspsearch.net/api/es2cmif";

import module namespace csQb="https://correspsearch.net/api/query-builder" at "csQuerybuilder.xqm";

declare namespace fn="http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare function local:correspDesc($letter as node()) {
let $source := $letter//fn:string[@key='source_id']/text()
let $key := $letter//fn:string[@key='key']/text()
let $ref := $letter//fn:map[@key='_source']/fn:string[@key='ref']/text()
return
    element correspDesc { 
(:        namespace {""} {"http://www.tei-c.org/ns/1.0"},:)
        attribute source { '#'||$source },
        if ($key) then attribute key {$key} else (),
        if ($ref) then attribute ref {$ref} else (),
        local:correspAction($letter, 'sent'),
        local:correspAction($letter, 'received')
    }
};

declare function local:correspAction($letter as node(), $type as xs:string) {
element correspAction {  
    attribute type { $type },
    for $person in $letter//fn:map[fn:string[@key='name_type']/text()='persName' and fn:string[@key='action']/text()=$type]
    return
    element persName {
        if ($person/fn:string[@key='canonical_ref']/text())
        then attribute ref { $person/fn:string[@key='canonical_ref']/text() } 
        else (),
        (: bei Bedarf canonical_name :)
        $person/fn:string[@key='text']/text()
    },
    for $place in $letter//fn:array[@key='places']/fn:map[.//fn:string[@key='action']/text()=$type]
    return
    element placeName {
        attribute ref { $place/fn:string[@key='canonical_ref']/text() },
        (: bei Bedarf canonical_name :)
        $place/fn:string[@key='text']/text()
    },
    for $date in $letter//fn:array[@key='dates']/fn:map[.//fn:string[@key='action']/text()=$type]/fn:map[@key='original_date']
    let $when := if ($date/fn:string/@key='when') then attribute when { $date/fn:string[@key='when']/text() } else ()
    let $from := if ($date/fn:string/@key='date_from') then attribute from { $date/fn:string[@key='date_from']/text() } else ()
    let $to := if ($date/fn:string/@key='date_to') then attribute to { $date/fn:string[@key='date_to']/text() } else ()
    let $notBefore := if ($date/fn:string/@key='not_before') then attribute notBefore { $date/fn:string[@key='not_before']/text() } else ()
    let $notAfter := if ($date/fn:string/@key='not_after') then attribute notAfter { $date/fn:string[@key='not_after']/text() } else ()
    let $text := if ($date/fn:string/@key='text') then $date/fn:string[@key='text']/text() else ()
    return
    element date {
        $when,
        $from,
        $to,
        $notBefore,
        $notAfter,
        $text
    }
}};

declare function local:notesStmt($jsonxml as node()) {
    let $total := xs:int($jsonxml//fn:map[@key='total']/fn:number/text())
    let $start := ((xs:int($csQb:p_x) - 1) * $csQb:size) + 1
    let $end-temp := (xs:int($csQb:p_x) * $csQb:size) 
    let $left-over := 
        if ($end-temp > $total)
        then false()
        else true()
    let $end := 
        if ($left-over)
        then $end-temp
        else $total
     let $relatedItem-prev :=
        if (xs:int($csQb:p_x) > 1) 
        then 
        element relatedItem { 
            attribute type {'prev'},
            attribute target {'https://correspsearch.net/api/v2.0/tei-xml.xql?'||replace($csQb:query-string, '&amp;x=\d+', '')||'&amp;x='||(xs:int($csQb:p_x) - 1)}} 
        else ()            
     let $relatedItem-next :=
        if ($left-over) 
        then 
        element relatedItem { 
            attribute type {'next'},
            attribute target {'https://correspsearch.net/api/v2.0/tei-xml.xql?'||replace($csQb:query-string, '&amp;x=\d+', '')||'&amp;x='||(xs:int($csQb:p_x) + 1)}} 
        else () 
    return
    <notesStmt xmlns="http://www.tei-c.org/ns/1.0">
        <note>{$start||'-'||$end||' of '||$jsonxml//fn:map[@key='total']/fn:number/text()} hits</note>
        {$relatedItem-prev}
        {$relatedItem-next}
    </notesStmt>
};

declare function local:respStmt($jsonxml as node()*) {
    let $all-ids := distinct-values($jsonxml//fn:array[@key='cmif_publishers']/fn:map/fn:string[@key="ref" and ./text()!='']/text())
    let $all-only-names := distinct-values($jsonxml//fn:array[@key='cmif_publishers']/fn:map[fn:string[@key="ref"]/text()='']/fn:string[@key="text"]/text())
    return
    if ($all-ids!='' or $all-only-names!='')
    then 
        element respStmt {
            element resp { 'Original data providers' },
            for $publisher_url in $all-ids 
            let $publisher := ($jsonxml//fn:array[@key='cmif_publishers']/fn:map[fn:string[@key='ref']/text()=$publisher_url])[1]
            let $publisher_name := $publisher/fn:string[@key='text']/text()
            return
            <name ref="{$publisher_url}">
                {$publisher_name}
            </name>,
            for $name in $all-only-names 
            return
            <name>
                {$name}
            </name>
        }
    else ()
};

declare function es2cmif:create-cmif($jsonxml as node()*) {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title>correspSearch API 2.0 (BETA)</title>
                    <editor>correspsearch@bbaw.de</editor>
                    {local:respStmt($jsonxml)}
                </titleStmt>
                <publicationStmt>
                    <publisher><ref target="https://www.bbaw.de/">Berlin-Brandenburg Academy of Sciences and Humanities</ref></publisher>
                    <availability>
                        <licence target="https://creativecommons.org/licenses/by/4.0/">CC-BY 4.0</licence>
                    </availability>
                    <idno type="url">https://correspsearch.net/api/v2.0/tei-xml.xql?{$csQb:query-string}</idno>
                    <date when="{current-dateTime()}"/>
                </publicationStmt>
                {local:notesStmt($jsonxml)}
                <sourceDesc>
                   {for $source_id in distinct-values($jsonxml//fn:string[@key='source_id']/text())
                    let $source := ($jsonxml//fn:map[@key='_source' and fn:string[@key='source_id']/text()=$source_id])[1]
                    let $source_text := $source/fn:string[@key='source_text']/text()
                    let $source_type := $source/fn:string[@key='source_type']/text()
                    let $source_ref :=
                        if ($source/fn:string[@key='source_ref'])
                        then 
                            <ref target="{$source/fn:string[@key='source_ref']}">{$source/fn:string[@key='source_ref_text']/text()}</ref>
                        else ()
                    return
                    <bibl xml:id="{$source_id}" type="{$source_type}">
                        {$source_text, $source_ref}
                    </bibl>}
                </sourceDesc>
            </fileDesc>
            <profileDesc>
               {for $letter in $jsonxml//fn:array[@key='hits']/fn:map
                return
                local:correspDesc($letter)} 
            </profileDesc>
        </teiHeader>
        <text>
            <body><p/></body>
        </text>
    </TEI>
};
