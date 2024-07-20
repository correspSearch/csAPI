xquery version "3.1";

import module namespace csBeacon="https://correspseaech.net/api/2.0/csAPI/Beacon" at "../modules/csBeacon.xqm";


let $name := request:get-parameter('name', ())

return
if ($name='beacon')
then csBeacon:create-cache()
else ()