xquery version "3.1";

import module namespace csBeacon="https://correspseaech.net/api/2.0/csAPI/Beacon" at "modules/csBeacon.xqm";

declare option exist:serialize "method=text media-type=text/plain"; 

let $authority := request:get-parameter('authority', 'gnd')

return
csBeacon:get-beacon($authority)