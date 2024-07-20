xquery version "3.1";

import module namespace csQb="https://correspsearch.net/api/query-builder" at "modules/csQuerybuilder.xqm";

response:stream(csQb:build-query(true()), 'media-type=application/json')