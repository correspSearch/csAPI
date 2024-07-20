xquery version "3.1";

import module namespace csAPI="https://correspseaech.net/api/2.0/csAPI" at "modules/csAPI.xqm";

declare option exist:serialize "method=text media-type=text/csv"; 

let $flavor := request:get-parameter('flavor', 'default')

return
csAPI:csv($flavor)