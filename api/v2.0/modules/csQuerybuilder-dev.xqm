xquery version "3.1";

module namespace csQb="https://correspsearch.net/api/query-builder/dev";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare variable $csQb:p_s := request:get-parameter('s', ());
declare variable $csQb:p_xs := request:get-parameter('xs', ());
declare variable $csQb:p_p := request:get-parameter('p', ());
declare variable $csQb:p_xp := request:get-parameter('xp', ());
declare variable $csQb:p_d := request:get-parameter('d', ());
declare variable $csQb:p_xd := request:get-parameter('xd', ());
declare variable $csQb:p_e := request:get-parameter('e', ());
declare variable $csQb:p_xe := request:get-parameter('xe', ());
declare variable $csQb:p_c := request:get-parameter('c', ());
declare variable $csQb:p_xc := request:get-parameter('xc', ());
declare variable $csQb:p_a := request:get-parameter('a', ());
declare variable $csQb:p_xa := request:get-parameter('xa', ());
declare variable $csQb:p_o := request:get-parameter('o', ());
declare variable $csQb:p_xo := request:get-parameter('xo', ());
declare variable $csQb:p_g := request:get-parameter('g', ());
declare variable $csQb:p_xg := request:get-parameter('xg', ());
declare variable $csQb:p_t := request:get-parameter('t', ());
declare variable $csQb:p_xt := request:get-parameter('xt', ());
declare variable $csQb:p_q := request:get-parameter('q', ());
declare variable $csQb:p_wl := request:get-parameter('wl', ());
declare variable $csQb:p_xwl := request:get-parameter('xwl', ());

declare variable $csQb:p_x := request:get-parameter('x', '1');
declare variable $csQb:p_order := request:get-parameter('order', 'asc'); 

declare variable $csQb:p_map := request:get-parameter('map', ());
declare variable $csQb:p_mr := request:get-parameter('mapr', ());

declare variable $csQb:p_vis := request:get-parameter('vis', ());

declare variable $csQb:size :=
    let $y := request:get-parameter('y', ())
    let $y :=
        if ($csQb:p_vis)
        then '20000'
        else if (matches($y, '^\d+$'))
        then 
            if (xs:int($y) <= 1000 )
            then $y 
            else '10'
        else '10'
    return
    xs:int($y)    
;

declare variable $csQb:query-string := request:get-query-string();

declare function local:cleanURI($uri as xs:string) as xs:string {
    if (matches($uri, 'https://d-nb.info/gnd/') or matches($uri, 'https://viaf.org/viaf/'))
    then replace($uri, 'https', 'http')
    else $uri
};

declare function csQb:tokenize-single-s-p-o($param-type as xs:string, $param-part as xs:string) {
        for $term in tokenize($param-part, '::')
        let $key := 
            if ($param-type='names.occupations')
            then 'names.occupations.canonical_ref'
            else if (matches($term, 'sent') or matches($term, 'received') or matches($term, 'mentioned'))
            then $param-type||'.action' 
            else $param-type||'.ref'
        return
            map {
                "term" : map {
                    $key : local:cleanURI($term)
                }}
};

(: besser als "nested" oder so benennen? :)
declare function csQb:subquery-s-p-o($param-type as xs:string, $param-value as xs:string, $bool-type as xs:string) {
    csQb:general-bool-wrap(
    for $param-part in tokenize($param-value, ',')       
    return
    map {
        "nested": map {
            "path" : $param-type,
            "query" : map {
                "bool" : 
                    if (matches($param-part, '::'))
                    then
                    map {
                        "must" : csQb:tokenize-single-s-p-o($param-type, $param-part)
                         }
                     else
                     map {
                        "must" : csQb:tokenize-single-s-p-o($param-type, $param-part),
                        "should" : 
                            [
                        		map { 
                        		  "term": map {
                        		      "names.action": "received"
                                   }
                                },
                        		map { 
                        		  "term": map {
                        	           "names.action": "sent"
                        		  }
                                }],
                          "minimum_should_match" : 1 
                     }
            }
        }
    },
    $bool-type)
};

declare function csQb:subquery-s-p-o($param-type as xs:string, $param-value as xs:string) {
    csQb:subquery-s-p-o($param-type, $param-value, 'must')
};

declare function csQb:subquery-e-c-a($param-type as xs:string, $param-value as xs:string, $bool-type as xs:string) {
    csQb:general-bool-wrap(
        map {
            "term" : map {
                $param-type : $param-value
            }
        },
    $bool-type)
};

(: Gender: derzeit noc heigene Funktion, weil leicht anders als die Query für Names sonst und Anpassungsbedarf noch nicht richtig absehbar :)
declare function csQb:subquery-gender($param-value as xs:string, $bool-type as xs:string) {
    csQb:general-bool-wrap(
    for $param-part in tokenize($param-value, ',')
    return
    map {
        "nested": map {
            "path" : 'names',
            "query" : map {
                "bool" : map {
                    "must" : [
                        map {
                        "term" : map {
                            "names.gender" : $param-part
                        }}]
                }
            }
        }
    },
    $bool-type)
};

declare function local:startOfPeriod($date) {
    let $proofedDate := 
        if (matches($date, '^\d\d\d\d$'))
        then (concat($date, '-01-01'))
        else (
            if (matches($date, '^\d\d\d\d-\d\d$'))
            then (
                if (matches($date, '^\d\d\d\d-\d\d$'))
                then (concat($date, '-01'))
                else ()
            ) else ($date)
        )
    return
    $proofedDate
};

declare function local:isLeapYear($date as xs:string) as xs:boolean {

let $year := xs:int(substring-before($date, '-'))

let $div-by-100 := not(matches(xs:string($year div 100), '\.'))
let $div-by-400 := not(matches(xs:string($year div 400), '\.'))

let $div-by-four := not(matches(xs:string($year div 4), '\.'))

let $is-leap-year :=
    if (($div-by-four and not($div-by-100)) or $div-by-400)
    then true()
    else false()

return
$is-leap-year    
};

declare function local:endOfPeriod($date) {
    let $proofedDate := 
        if (matches($date, '\d\d\d\d$'))
        then (concat($date, '-12-31'))
        else (
            if (matches($date, '\d\d\d\d-\d\d$'))
            then (
                if (matches($date, '\d\d\d\d-02$') and local:isLeapYear($date))
                then (concat($date, '-29'))
                else if (matches($date, '\d\d\d\d-02$'))
                then (concat($date, '-28'))
                else (
                    if (matches($date, '\d\d\d\d-(01|03|05|07|08|10|12)$'))
                    then (concat($date, '-31'))
                    else (concat($date, '-30'))
                )
            ) else ($date)
        )
    return
    $proofedDate
};

declare function csQb:subquery-d($param-value as xs:string) {
    csQb:subquery-d($param-value, 'should')
};

declare function csQb:subquery-d($param-value as xs:string, $bool-type as xs:string) {
    csQb:general-bool-wrap(
    for $param-part in tokenize($param-value, ',')
    let $search-dates := 
        if (matches($param-part, '\d\d\d\d-\d\d-\d\d-\d\d\d\d-\d\d-\d\d'))
        then 
            map {
                "lte" : replace($param-part, '(\d\d\d\d-\d\d-\d\d)-(\d\d\d\d-\d\d-\d\d)', '$2'),
                "gte" : replace($param-part, '(\d\d\d\d-\d\d-\d\d)-(\d\d\d\d-\d\d-\d\d)', '$1')
            }
        else if (matches($param-part, '\d\d\d\d-\d\d\d\d'))
        then 
            map {
                "lte" : local:endOfPeriod(replace($param-part, '(\d\d\d\d)-(\d\d\d\d)', '$2')),
                "gte" : local:startOfPeriod(replace($param-part, '(\d\d\d\d)-(\d\d\d\d)', '$1'))
            }            
        else if (matches($param-part, '\d\d\d\d-\d\d-\d\d'))
        then 
            map {
                "lte" : $param-part,
                "gte" : $param-part
            }
        else if (matches($param-part, '\d\d\d\d-\d\d') or matches($param-part, '\d\d\d\d'))
        then 
            map {
                "lte" : local:endOfPeriod($param-part),
                "gte" : local:startOfPeriod($param-part)
            }    
        else ($param-part)  
    return        
    map {
        "nested": map {
            "path" : "dates",
            "query" : map {
                "bool" : map {
                    "must" : [
                        map {
                            "range": map {
                                "dates.start" : map {
                                    "lte" : $search-dates('lte')
                                }
                            }
                        },
                        map {
                            "range": map {
                                "dates.end" : map { 
                                    "gte" : $search-dates('gte')
                                 }    
                            }
                        }
                        ]
                     }   
                }
            }
        },
    $bool-type)
};

declare function csQb:subquery-fulltext($param-value as xs:string) {
   csQb:general-bool-wrap(
   map {
        "simple_query_string": map{
          "query": $param-value,
          "fields": [
            "full_text",
            "editorial_notes",
            "abstract"
          ],
          "default_operator": "and"
        }
    },
    'must')
};

declare function csQb:general-bool-wrap($map as map()*, $bool-type as xs:string) {
    map {
        "bool": map {
            $bool-type : $map               
         }
     }
};

declare function csQb:build-query() {
 csQb:build-query(false(), $csQb:size, xs:int($csQb:p_x))
};

declare function csQb:build-query($aggregation as xs:boolean) {
 csQb:build-query($aggregation, $csQb:size, xs:int($csQb:p_x))
};

declare function csQb:build-query($aggregation as xs:boolean, $size as xs:int, $page as xs:int) {

let $offset := $size * ($page - 1)

let $names :=
    if ($csQb:p_s)
    then csQb:subquery-s-p-o('names', $csQb:p_s)
    else ()

let $x-names :=
    if ($csQb:p_xs)
    then csQb:subquery-s-p-o('names', $csQb:p_xs, 'must_not')
    else ()

let $places :=
    if ($csQb:p_p)
    then csQb:subquery-s-p-o('places', $csQb:p_p)
    else ()
    
let $x-places :=
    if ($csQb:p_xp)
    then csQb:subquery-s-p-o('places', $csQb:p_xp, 'must_not')
    else ()    

let $dates := 
    if ($csQb:p_d)
    then csQb:subquery-d($csQb:p_d)
    else ()
    
let $x-dates := 
    if ($csQb:p_xd)
    then csQb:subquery-d($csQb:p_xd, 'must_not')
    else ()    

let $occupations :=
    if ($csQb:p_o)
    then csQb:subquery-s-p-o('names.occupations', $csQb:p_o)
    else ()

let $x-occupations :=
    if ($csQb:p_xo)
    then csQb:subquery-s-p-o('names.occupations', $csQb:p_xo, 'must_not')
    else ()

let $gender :=
    if ($csQb:p_g)
    then csQb:subquery-gender($csQb:p_g, 'must')
    else ()

let $x-gender :=
    if ($csQb:p_xg)
    then csQb:subquery-gender($csQb:p_xg, 'must_not')
    else ()

let $fulltext :=
    if ($csQb:p_q)
    then csQb:subquery-fulltext($csQb:p_q)
    else ()
    
let $fulltext-highlighting := 
    if ($csQb:p_q)
    then
        map {
            "fields": map {
                "full_text": map {},
                "editorial_notes" : map {},
                "abstract" : map {}
            },
            "fragment_size": 300
        }
    else (map {})

let $languages :=
    if ($csQb:p_wl)
    then csQb:subquery-s-p-o('languages', $csQb:p_wl)
    else ()
    
let $x-languages :=
    if ($csQb:p_xwl)
    then csQb:subquery-s-p-o('languages', $csQb:p_xwl, 'must_not')
    else ()    

let $datasets :=
    if ($csQb:p_t)
    then csQb:subquery-s-p-o('datasets', $csQb:p_t)
    else ()
    
let $x-datasets :=
    if ($csQb:p_xt)
    then csQb:subquery-s-p-o('datasets', $csQb:p_xt, 'must_not')
    else ()    

let $editions :=
    if ($csQb:p_e)
    then csQb:subquery-e-c-a('source_id', $csQb:p_e, 'should')
    else ()
    
let $x-editions :=
    if ($csQb:p_xe)
    then csQb:subquery-e-c-a('source_id', $csQb:p_xe, 'must_not')
    else ()    
    
let $cmif :=
    if ($csQb:p_c)
    then csQb:subquery-e-c-a('cmif_idno', $csQb:p_c, 'should')
    else ()

let $x-cmif :=
    if ($csQb:p_xc)
    then csQb:subquery-e-c-a('cmif_idno', $csQb:p_xc, 'must_not')
    else ()
    
let $source-type :=     
    if ($csQb:p_a)
    then csQb:subquery-e-c-a('source_type', $csQb:p_a, 'must')
    else ()

let $x-source-type :=     
    if ($csQb:p_xa)
    then csQb:subquery-e-c-a('source_type', $csQb:p_xa, 'must_not')
    else ()

(: ONLY MAPBASED SEARCH :)    
let $filter-geocoordinates := 
    if ($csQb:p_map)
    then
        let $coordinates := parse-json(util:base64-decode(request:get-data()))?*
        let $subquery-coordinates :=
            map {
        		"geo_shape": map {
        			"places.location": map {
        				"shape": map {
        					"type": "multipolygon",
        					"coordinates" : $coordinates
        				},
        				"relation": "within"
        			}
        		}
             }
        let $map_sent-or-received := 
                if ($csQb:p_mr='sent' or $csQb:p_mr='received')
                then
                    map {
                        "term" : map {
                            "places.action" : $csQb:p_mr
                        }
                    }
                else ()
        let $subquery := 
            for $map in ($subquery-coordinates, $map_sent-or-received)
            return
            $map
        return
        map {
        	"nested": map {
        		"path": "places",
        		"query": map {
        			"bool": map {
        				"must": $subquery   
        	         }
                 }
            }
        }
    else (map{})

(: ONLY VISUALISIATION :)
let $_source := 
if ($csQb:p_vis)
then
        (
            "names.canonical_ref",
            "names.canonical_name",
            "names.gender",
            "names.text",
            "names.action",
            "names.birth_date",
            "names.death_date",
            "places.canonical_ref",
            "places.canonical_name_de",
            "places.canonical_name_en",
            "places.location",
            "places.action",
            "places.text",
            "dates.action",
            "dates.start",
            "dates.end"
        )
else map{}


(: additional FLOWR for subqueries to avoid "null" in JSON output, if a parameter isn't present :)
let $subqueries :=
    for $subquery in ($names, $x-names, $places, $x-places, $dates, $x-dates, $occupations, $x-occupations, $gender, $x-gender, $fulltext, $languages, $x-languages, $datasets, $x-datasets, $editions, $x-editions, $cmif, $x-cmif, $source-type, $x-source-type) 
    return
    $subquery

let $aggs := 
    if ($aggregation and $csQb:p_vis)
    then json-doc('/db/apps/csAPI/api/v2.0/modules/csQb_vis_aggregations.json')
    else if ($aggregation and $csQb:p_map)
    then json-doc('/db/apps/csAPI/api/v2.0/modules/csQb_mapsearch_aggregations.json')
    else if ($aggregation)
    then json-doc('/db/apps/csAPI/api/v2.0/modules/csQb_aggregations.json')
    else (map {})

let $query := 
    map {
        'from' : $offset,
        'size' : $size,
        "track_total_hits" : 100000,
        "sort" : map {
            "dates.start" : map {
                "order": $csQb:p_order,
                "nested" : map {
                    "path" : "dates"
                }
            }
        },
        "aggs" : $aggs,
        "_source" : $_source, 
        "query" : map {
            "bool" : 
                if ($csQb:p_map)
                then 
                    map {
                        "must" : $subqueries,
                        "filter" : $filter-geocoordinates
                }
                else
                    map {
                        "must" : $subqueries
                    }
        },
        "highlight" : $fulltext-highlighting 
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
