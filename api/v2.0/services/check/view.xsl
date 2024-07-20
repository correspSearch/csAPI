<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" exclude-result-prefixes="xs svrl" version="2.0">
    
    <xsl:variable name="number-all-letters" select="count(//tei:correspDesc)"/>
    
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
                    
                    a#preview {
                        position: absolute;
                        right: 0.5em;
                        bottom: 1em;
                    }
                </style>
            </head>       
        <body>
            <div id="navbar" class="outerWrap">
                <div class="innerWrap">
                    <h1>
                        <a href="https://correspSearch.net/index.xql?l=de">correspSearch</a> | CMIF Check</h1>
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
                        <xsl:if test="matches(//tei:idno[@type='url'], 'https?://')">
                            <a id="preview" href="../cmif-preview.xql?url={//tei:idno[@type='url']}" class="button">Preview</a>
                        </xsl:if>
                    </div>
                </div>
            </div>
            <div class="outerWrap contentBottom">
                <div class="container_12">
                    <div class="grid_12">
                        <div class="box">
                            <h2>RNG Validation Results</h2>
                            <xsl:apply-templates select="//report"/>
                        </div>
                        <div class="box">
                            <h2>Schematron Validation Results</h2>
                            <xsl:apply-templates select="//svrl:schematron-output"/>
                        </div>
                        <div class="box">
                            <h2>GeoNames Check</h2>
                            <xsl:apply-templates select="//geonames"/>
                        </div>
                        
                    </div>
                </div>
            </div>
        </body></html>
    </xsl:template>
      
    <xsl:template match="report">
        <p>Status: <xsl:value-of select="./status"/></p>
        <table>
            <tr>
                <th>Line</th>
                <th>Error message</th>
            </tr>
            <xsl:for-each select="./message">
                <tr>
                    <td><xsl:value-of select="@line"/></td>
                    <td><xsl:value-of select="./text()"/></td>
                </tr>
            </xsl:for-each>
            
        </table>
    </xsl:template>
    
    <xsl:template match="svrl:schematron-output">
        <table>
            <tr>
                <th>Level</th>
                <th>Message</th>
                <th>Location</th>
            </tr>
        <xsl:for-each select="svrl:failed-assert">
            <tr>
                <td><xsl:value-of select="@role"/></td>
                <td><xsl:value-of select=".//text()"/></td>
                <td><xsl:value-of select="replace(@location, 'Q\{http://www.tei-c.org/ns/1.0\}', '')"/></td>
            </tr>
        </xsl:for-each>
        </table>
    </xsl:template>
    
    <xsl:template match="geonames">
        <p><xsl:value-of select="places"/> places, <xsl:value-of select="errors"/> of them with the following error messages</p>
        <table>
            <tr>
                <th>Name (in CMIF)</th>
                <th>URI</th>
                <th>Feature class</th>
                <th>Error</th>
            </tr>
            <xsl:for-each select="place">
                <tr>
                    <td><xsl:value-of select="tei-name"/></td>
                    <td><xsl:value-of select="uri"/></td>
                    <td><xsl:value-of select="gn-class"/></td>
                    <td><xsl:value-of select="error"/></td>
                </tr>
            </xsl:for-each>    
        </table>
    </xsl:template>
    
</xsl:stylesheet>