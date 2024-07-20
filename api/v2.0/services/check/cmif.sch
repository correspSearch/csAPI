<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt2">
    
    <title>Schematron extension of the Correspondence Metadata Interchange Format (CMIF)</title>
    
    <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
    
    <pattern id="ref">
        <rule context="tei:ref">
            <assert test="matches(@target, '^https?://[-a-zA-Z0-9+&amp;@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&amp;@#/%=~_|]')" role="error">
                [E0002] URL in ref not available or misspelled.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="idno">
        <rule context="tei:idno[@type='url']">
            <assert test="matches(./text(), '^(https?|ftp|file)://[-a-zA-Z0-9+&amp;@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&amp;@#/%=~_|]')" role="error">
                [E0001] URL in publicationStmt/idno not available or misspelled.
            </assert>
        </rule>
    </pattern>
        
    <pattern id="bibl">
        <rule context="tei:bibl">
            <assert test="matches(@xml:id, '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')" role="warning">
                [W0001] It is recommended to use an UUID for bibl/@xml.
            </assert>
            <assert test="./@xml:id=ancestor::tei:TEI//tei:correspDesc/substring-after(@source, '#')" role="warning">
                [W0002] The ID in bibl/@xml:id is not referenced by any correspDesc/@source. 
            </assert>
        </rule>
    </pattern>
    
    <pattern id="bibl-ref">
        <rule context="tei:bibl/tei:ref">
            <assert test="not(matches(./following-sibling::text(), '[a-z]'))" role="warning">
                [W0001] A tei:ref element should be at the end of the bibliographic citation.
            </assert>
            <assert test="./text() and @target" role="error">
                [E0000] A tei:ref element in bibl MUST NOT be emtpy! I.e. the link has to be encoded as attribute @target as well as text content of the element ref.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="correspDesc">
        <rule context="tei:correspDesc">
            <assert test="tei:correspAction[@type='sent']" role="error">
                [E0001] Element "&lt;correspAction type="sent"/&gt;" must be present.
            </assert>
            <assert test="tei:correspAction[@type='received']" role="error">
                [E0002] Element "&lt;correspAction type="received"/&gt;" must be present.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="source">
        <rule context="tei:correspDesc/@source">
            <assert test="substring-after(., '#')=ancestor::tei:TEI//tei:bibl/@xml:id" role="error">
                [E0003] correspDesc/@source does not correspond to a bibl/@xml:id.
            </assert>
        </rule>
    </pattern>    
    
    <pattern>
        <rule context="tei:correspAction">
            <assert test="tei:persName or tei:orgName">
                [E0000] correspAction must have at least one child element persName or orgName.  
            </assert>
        </rule>
    </pattern>
    
    <let name="authority-files-persons" value="'(https?://d-nb\.info/gnd/|https?://viaf\.org/viaf/|https?://catalogue\.bnf\.fr/ark:/12148/|https?://lccn\.loc\.gov/|https?://id\.ndl\.go\.jp/auth/ndlna/)'"/>
    
    <pattern>
        <rule context="tei:persName|tei:orgName">
            <assert test="./text()">
                [E0000] The element persName must not be empty.   
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="tei:persName[@ref]|tei:orgName[@ref]">
            <assert test="matches(@ref, $authority-files-persons)">
                [W0000] Used authority file system is not supported. Supported authority files are: VIAF, GND, LC, BnF and NDL.
            </assert>
        </rule>
    </pattern>

    <pattern>
        <rule context="tei:placeName/@ref">
            <assert test="matches(., 'https?://(www|sws).geonames.org/\d+')">
                [W0000] URI must be a valid GeoNames URI. 
            </assert>
            <assert test="not(matches(., '.html'))">
                [E0000] GeoNames-URI must match the pattern "https://www.geonames.org/XXXXXXXX" - i.e. without "/[placename].html" 
            </assert>
        </rule>
    </pattern>
    
    <pattern id="date">
        <rule context="tei:date">
            <assert test="@when or @from or @to or @notBefore or @notAfter" role="error">
                [E0004] At least one dating attribute (@when, @from etc.) must be present. 
            </assert>
            <assert test="not(matches(./text(), '\d\d?\.\s[A-Za-zä]+\s\d\d\d\d'))" role="info">
                [W0001] We recommend to provide the date as (human-readable) text only in such cases where the machine-readable form would lead to a lack of information.
            </assert>
        </rule>
    </pattern>
    
    <!-- fehlt: 
        - Warnung bei fehlendem ref (?) oder anders auswerten? 
        - Warnung bei nicht-unterstützter Normdatei  
        - nochmal Issue checken
        -->
    
</schema>