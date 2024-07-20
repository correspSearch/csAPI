<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://correspSearch.net/functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:wgs84_pos="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs tei" version="2.0">
            
    <xsl:variable name="doc" select="/"/>            

    <xsl:variable name="number-all-letters" select="count(//tei:correspDesc)"/>

    <xsl:function name="cs:percentage">
        <xsl:param name="numerator"/>
        <xsl:param name="denominator"/>
        <xsl:choose>
            <xsl:when test="$denominator = 0">
                <xsl:value-of select="0"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="round(($numerator div $denominator) * 100)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="https://correspsearch.net/resources/css/v1/reset.css" media="all"/>
                <link rel="stylesheet" type="text/css" href="https://correspsearch.net/resources/css/v1/960.css" media="screen"/>
                <link rel="stylesheet" type="text/css" href="https://correspsearch.net/resources/css/v1/main.css" media="all"/>
                                
                <style>
                    div#diagram-box {
                        overflow-x: auto;
                    }
                    svg#diagram rect:hover {
                    fill: #F7931E;
                    }
                    
                    .contentTop table td,
                    .contentTop table th {
                        color: white;
                        border: none;
                        padding: 0 1em 0 1em;
                        border-right: 1px solid white;
                    }
                    
                    .contentTop table td:first-of-type,
                    .contentTop table th:first-of-type {
                        padding-left: 0;
                    }
                    
                    .contentTop table td:last-of-type,
                    .contentTop table th:last-of-type {
                        border-right: none;
                    }
                    
                    li.box p.date { 
                        font-size: 1.1em;
                        width: 9em;
                    } 
                    
                    .place {
                        font-size: 0.7em;
                    }
                    
                    li.box h3.correspondents {
                        padding-left: 10.8em;
                    }
                    
                    li.box p.editionStmt, li.box p.more {
                        padding-left: 13em;
                    }
                    div.cs-important {
                        border: 1px solid #F7931E;
                        border-left: 10px solid #F7931E;
                        padding: 0.8em;
                        background-color: white;
                        font-family: PTSans;
                    }
                    div.cs-important p {
                        margin: 0;
                    }
                    div.cs-important svg {
                        float: left;
                        padding-right: 1em;
                    }
                </style>
            </head>
        </html>           
        <body>
            <div id="navbar" class="outerWrap">
                <div class="innerWrap">
                    <h1>
                        <a href="https://correspSearch.net/index.xql?l=de">correspSearch</a> | CMIF Preview</h1>
                </div>
            </div>
            <div class="outerWrap contentTop">
                <div class="container_12">
                    <div class="grid_12 center">
                        <h1>
                            <xsl:value-of select="//tei:title"/>
                        </h1>
                        <table>
                            <tr>
                                <th>Ersteller</th>
                                <th>Lizenz</th>
                                <th>Briefe</th>
                                <th>Korrespondenten</th>
                                <th>Orte</th>
                                <th>CMIF-URL</th>
                            </tr>
                            <tr>
                                <td>
                                    <xsl:value-of select="//tei:titleStmt/tei:editor/text()"/>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="matches(//tei:licence[1]/@target, 'https://creativecommons.org/licenses/by/4.0/')">
                                            <xsl:text>CC BY 4.0</xsl:text>  
                                        </xsl:when>
                                        <xsl:when test="matches(//tei:licence[1]/@target, 'https://creativecommons.org/publicdomain/zero/1.0/')">
                                            <xsl:text>CC0</xsl:text>  
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>Nicht erlaubte Lizenz</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td>
                                    <xsl:value-of select="$number-all-letters"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(distinct-values(//tei:persName/text()))"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(distinct-values(//tei:placeName/text()))"/>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="matches(//tei:idno[@type='url'], 'https?://')">
                                            <a href="{//tei:idno[@type='url']}">Aufrufen</a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            [Nicht vorhanden]
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
            <div class="outerWrap contentBottom">
                <div class="container_12">
                    <div class="grid_4">
                        <div class="box">
                            <h3 class="first">Statistik</h3>
                            <xsl:variable name="identified-persons">
                                <xsl:variable name="all">
                                    <xsl:value-of select="count(//(tei:persName|tei:orgName))"/>
                                </xsl:variable>
                                <xsl:variable name="identified">
                                    <xsl:value-of select="count(//(tei:persName[matches(@ref, 'gnd|viaf')]|tei:orgName[matches(@ref, 'gnd|viaf')]))"/>
                                </xsl:variable>
                                <xsl:value-of select="cs:percentage($identified, $all)"/>
                            </xsl:variable>
                            <xsl:variable name="identified-places">
                                <xsl:variable name="all">
                                    <xsl:value-of select="count(//(tei:placeName))"/>
                                </xsl:variable>
                                <xsl:variable name="identified">
                                    <xsl:value-of select="count(//tei:placeName[matches(@ref, 'geonames')])"/>
                                </xsl:variable>
                                <xsl:value-of select="cs:percentage($identified, $all)"/>
                            </xsl:variable>
                            <xsl:variable name="places-of-reception" select="cs:percentage(count(//tei:correspDesc[tei:correspAction[@type='received']/tei:placeName]), $number-all-letters)"/>
                            <xsl:variable name="dated-exactly" select="cs:percentage(count(//tei:correspDesc[tei:correspAction[@type='sent']/tei:date/(@when|@from|@to)]), $number-all-letters)"/>
                            <xsl:variable name="dated-approx" select="cs:percentage(count(//tei:correspDesc[tei:correspAction[@type='sent']/tei:date/(@notBefore|@notAfter)]), $number-all-letters)"/>
                            <xsl:variable name="undated" select="cs:percentage(count(//tei:correspDesc[not(tei:correspAction[@type='sent']/tei:date/@*)]), $number-all-letters)"/>
                            
                            <svg xmlns="http://www.w3.org/2000/svg" id="statSvg" width="100%" height="200" fill="grey">
                                <text x="0" y="20" font-size="12" font-family="PTSans" fill="#404040">Personen mit GND-ID</text>
                                <rect x="0" y="25" width="100%" height="20" rx="3" ry="3" fill="#e0e0e0"/>
                                <rect x="0" y="25" width="{$identified-persons}%" height="20" rx="3" ry="3" fill="#7EB22A"/>
                                <text x="{$identified-persons - 12}%" y="39" font-size="12" font-family="PTSans" fill="white">
                                    <xsl:value-of select="$identified-persons"/>%</text>
                                
                                <text x="0" y="70" font-size="12" font-family="PTSans" fill="#404040">Orte mit GeoNames-ID</text>
                                <rect x="0" y="75" width="100%" height="20" rx="3" ry="3" fill="#e0e0e0"/>
                                <rect x="0" y="75" width="{$identified-places}%" height="20" rx="3" ry="3" fill="#7EB22A"/>
                                <text x="{$identified-places - 12}%" y="89" font-size="12" font-family="PTSans" fill="white">
                                    <xsl:value-of select="$identified-places"/>%</text>
                                
                                <text x="0" y="120" font-size="12" font-family="PTSans" fill="#404040">Briefe mit Empfangsorten</text>
                                <rect x="0" y="125" width="100%" height="20" rx="3" ry="3" fill="#e0e0e0"/>
                                <rect x="0" y="125" width="{$places-of-reception}%" height="20" rx="3" ry="3" fill="#7EB22A"/>
                                <text x="{$places-of-reception - 12}%" y="139" font-size="12" font-family="PTSans" fill="white">
                                    <xsl:value-of select="$places-of-reception"/>%</text>
                                
                                <text x="0" y="170" font-size="12" font-family="PTSans" fill="#404040">Datierungen (genau / ungefähr / undatiert)</text>
                                <rect x="0" y="175" width="100%" height="20" rx="3" ry="3" fill="#e0e0e0"/>
                                <rect x="0" y="175" width="{$dated-exactly}%" height="20" fill="#7EB22A"/>
                                <rect x="{$dated-exactly}%" y="175" width="{$dated-approx}%" height="20" fill="#eac73a"/>
                                <rect x="{$dated-approx + $dated-exactly}%" y="175" width="{$undated}%" height="20" rx="3" ry="3" fill="#af2a2a"/>
                            </svg>
                        </div>
                    </div>
                    
                    <div class="grid_8 omega">
                        <div class="box">
                            <h3 class="first">Zeitverlauf</h3>
                            <xsl:variable name="all-years">
                                <xsl:for-each select="//tei:correspAction/tei:date/(@when|@from|@to|@notBefore|@notAfter)">
                                    <xsl:sort select="."/>
                                    <xsl:choose>
                                        <xsl:when test="matches(., '^\d\d\d\d$')">
                                            <year>
                                                <xsl:value-of select="."/>
                                            </year>
                                        </xsl:when>
                                        <xsl:when test="matches(., '^\d\d\d\d-\d\d$')">
                                            <year>
                                                <xsl:value-of select="substring-before(., '-')"/>
                                            </year>
                                        </xsl:when>
                                        <xsl:when test="matches(., '\d\d\d\d-\d\d-\d\d')">
                                            <year>
                                                <xsl:value-of select="substring-before(., '-')"/>
                                            </year>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:variable>
                        
                            <xsl:variable name="first-year" select="$all-years/year[1]/text()"/>
                            <xsl:variable name="last-year">
                                <xsl:value-of select="xs:double(max($all-years/year))"/>
                            </xsl:variable>
                        
                         <xsl:variable name="years">
                                <xsl:for-each select="$first-year to $last-year">
                                    <xsl:variable name="year">
                                        <xsl:value-of select="."/>
                                    </xsl:variable>
                                <year key="{$year}" value="{count($doc//tei:correspAction[@type='sent']/tei:date[contains((@when|@from|@notBefore), $year)])}"/>                                
                            </xsl:for-each>
                        </xsl:variable>

                        <xsl:variable name="max-year" select="max($years/year/@value)"/>
       
                        <div id="diagram-box">
                            <svg xmlns="http://www.w3.org/2000/svg" id="diagram" width="{(count($years/year) * 10)+20}" height="184px" fill="grey">
                            <line x1="0" x2="{(count($years/year)*10)+5}" y1="157" y2="157" stroke="gray" stroke-width="1"/>
                            <line x1="0" x2="0" y1="0" y2="157" stroke="gray" stroke-width="1"/>
                            <text x="0" y="170" font-size="12" font-family="PTSans" fill="#404040">
                                        <xsl:value-of select="$years/year[1]/@key"/>
                                    </text>
                            <xsl:for-each select="$years/year">
                                <rect x="{xs:double(concat(position()-1, 0))+2}" y="{85 - ((./@value div $max-year) * 100)}%" width="9" height="{(./@value div $max-year) *100}%" fill="#2A7299">
                                    <title>
                                                <xsl:value-of select="./@key"/>: <xsl:value-of select="./@value"/>
                                            </title>
                                </rect>
                                <xsl:if test="matches(./@key, '\d\d\d0') and position() &gt; 5 and (position() &lt; (count($years/year)-5))">
                                    <text x="{xs:double(concat(position()-1, 0))}" y="170" font-size="12" font-family="PTSans" fill="#404040">
                                                <xsl:value-of select="./@key"/>
                                            </text>
                                </xsl:if>
                            </xsl:for-each>
                            <text x="{(count($years/year)*10)-20}" y="170" font-size="12" font-family="PTSans" fill="#404040">
                                        <xsl:value-of select="$years/year[last()]/@key"/>
                                    </text>
                            </svg>
                            </div>
                        </div>
                        
                    </div>
                    
                    <div class="grid_12">
                        <div class="box cs-important">
                            <p>Bitte beachten Sie: Diese Voransicht dient nur als Hilfe zur Überprüfung. Es werden keine Daten in
                            correspSearch gespeichert. Möchten Sie eine CMIF-Datei beim Webservice registrieren, kontaktieren Sie 
                            uns unter <a href="mailto:correspSearch@bbaw.de">correspsearch@bbaw.de</a>.</p>
                            
                        </div>
                        <ul class="searchresult">
                            <xsl:apply-templates select="//tei:correspDesc">
                                <xsl:sort select="tei:correspAction[@type='sent']/tei:date/(@when|@from|@notBefore)"/>
                            </xsl:apply-templates>
                        </ul>
                    </div>
                </div>
            </div>
        </body>
    </xsl:template>
    
    <xsl:template match="tei:correspDesc">
        <xsl:variable name="bibl-id">
            <xsl:value-of select="substring-after(@source, '#')"/>
        </xsl:variable>
        <li class="box">
            <p class="date">
                <span>
                    <xsl:apply-templates select="tei:correspAction[@type='sent']/tei:date"/>
                </span>
                <span class="place sender">
                    <xsl:value-of select="tei:correspAction[@type='sent']/tei:placeName"/>
                </span>
                <span class="place addressee">
                    <xsl:value-of select="tei:correspAction[@type='received']/tei:placeName"/>
                </span>
            </p>
            <h3 class="correspondents">
                <xsl:call-template name="correspondents"/>
            </h3>
            <p class="editionStmt">
                <xsl:apply-templates select="//tei:bibl[@xml:id=$bibl-id]"/>
            </p>
            <p class="more">
                <xsl:choose>
                    <xsl:when test="@ref and @key">
                        <a href="{@ref}">Brief Nr. <xsl:value-of select="@key"/>
                        </a>
                    </xsl:when>
                    <xsl:when test="@ref">
                        <a href="{@ref}">Zum Brief</a>        
                    </xsl:when>
                    <xsl:when test="@key">
                        <xsl:text>Brief Nr. </xsl:text>
                        <xsl:value-of select="@key"/>
                    </xsl:when>
                    <xsl:otherwise>
                        [Keine Brief-Nr. oder URL angegeben]
                    </xsl:otherwise>
                </xsl:choose>
            </p>
        </li>
    </xsl:template>
    
    <xsl:template name="correspondents">
        <xsl:for-each select="tei:correspAction[@type='sent']/(tei:persName|tei:orgName)">
            <xsl:choose>
                <xsl:when test="position()=1">
                    <xsl:value-of select="."/>        
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:text> an </xsl:text>
        <xsl:for-each select="tei:correspAction[@type='received']/(tei:persName|tei:orgName)">
            <xsl:choose>
                <xsl:when test="position()=1">
                    <xsl:value-of select="."/>        
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
        
    <xsl:template match="tei:date">
        <xsl:choose>
            <xsl:when test="@when">
                <xsl:apply-templates select="@when"/>
            </xsl:when>
            <xsl:when test="@to">
                <xsl:apply-templates select="@from"/>
                <xsl:text> bis </xsl:text>
                <xsl:apply-templates select="@to"/> 
            </xsl:when>
            <xsl:when test="(@notBefore and @notAfter) and (@notBefore=@notAfter)">
                <xsl:apply-templates select="@notBefore"/> 
            </xsl:when>
            <xsl:when test="@notBefore and @notAfter">
                <xsl:text>Nicht vor </xsl:text>
                <xsl:apply-templates select="@notBefore"/>
                <xsl:text> und nicht nach </xsl:text>
                <xsl:apply-templates select="@notAfter"/> 
            </xsl:when>
            <xsl:when test="@notBefore">
                <xsl:text>Nicht vor </xsl:text>
                <xsl:apply-templates select="@notBefore"/> 
            </xsl:when>
            <xsl:when test="@notAfter">
                <xsl:text>Nicht nach </xsl:text>
                <xsl:apply-templates select="@notAfter"/> 
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="cs:months">
        <xsl:param name="no"/>
        <xsl:variable name="months">
            <months>
                <month key="01" label="Januar"/>
                <month key="02" label="Februar"/>
                <month key="03" label="März"/>
                <month key="04" label="April"/>
                <month key="05" label="Mai"/>
                <month key="06" label="Juni"/>
                <month key="07" label="Juli"/>
                <month key="08" label="August"/>
                <month key="09" label="September"/>
                <month key="10" label="Oktober"/>
                <month key="11" label="November"/>
                <month key="12" label="Dezember"/>
            </months>
        </xsl:variable>
        <xsl:value-of select="$months//*[@key=$no]/@label"/>
    </xsl:function>
    
    <xsl:template match="@when|@from|@to|@notBefore|@notAfter">        
        <xsl:choose>
            <xsl:when test="matches(., '\d\d\d\d-\d\d-\d\d')">
                <xsl:value-of select="concat(substring(., 9, 2), '. ', cs:months(substring(., 6, 2)), ' ', substring(., 1, 4))"/>
            </xsl:when>
            <xsl:when test="matches(., '\d\d\d\d-\d\d')">
                <xsl:value-of select="concat(cs:months(substring(., 6, 2)), ' ', substring(., 1, 4))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:ref">
        <a href="{@target}">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>
    
</xsl:stylesheet>