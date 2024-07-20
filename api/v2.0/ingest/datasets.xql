xquery version "3.1";

import module namespace csAPI="https://correspseaech.net/api/2.0/csAPI" at "../modules/csAPI.xqm";

declare option exist:serialize "media-type=application/json";

let $cmif-url := request:get-parameter('url', ())

let $datasets :=
    for $cmif-file in doc($csAPI:harvester-data||'/cmif-file-index.xml')//file[@url=$cmif-url]
    return 
        for $dataset in tokenize($cmif-file/@datasets/data(.))
        let $id := $dataset
        let $label_de := collection($csAPI:harvester-data||'/datasets/')//cs-dataset[id=$id]/label[@xml:lang="de"]/text()
        let $label_en := collection($csAPI:harvester-data||'/datasets/')//cs-dataset[id=$id]/label[@xml:lang="en"]/text()
        return
        map {
        'id' : $id,
        'label_de' : $label_de,
        'label_en' : $label_en 
        }
  
return
serialize($datasets, map { 'method': 'json'})