<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:json="http://james.newtonking.com/projects/json" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">

    <xsl:param name="generated-uuid"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Clean up @xml:id from CSV2CMI & others -->
    <xsl:template match="tei:titleStmt/tei:title/@xml:id"/>
    <xsl:template match="tei:titleStmt/tei:title/@type"/>
    <xsl:template match="tei:titleStmt/tei:respStmt"/>
    <xsl:template match="tei:correspAction/@xml:id"/>
    <xsl:template match="tei:idno[@type='handle']"/>
    <xsl:template match="tei:idno[@type='PID']"/>
    <xsl:template match="tei:correspDesc/tei:note">
        <xsl:choose>
            <xsl:when test="tei:ref[@type='cmif:hasLanguage' or @type='cmif:fulltext']">
                <note xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each select="tei:ref[@type='cmif:hasLanguage']">
                        <tei:ref type="https://lod.academy/cmif/ns/terms#hasLanguage" target="{@target/data(.)}" json:array="true"><xsl:value-of select="."/></tei:ref>
                    </xsl:for-each>
                    <xsl:for-each select="tei:ref[@type='cmif:fulltext' or @type='cmif:hasFulltext']">
                        <tei:ref type="https://lod.academy/cmif/ns/terms#fulltext" target="{@target/data(.)}" json:array="true"/>
                    </xsl:for-each>
                </note>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:correspDesc[not(@source)]"/>
    <xsl:template match="tei:correspDesc[not(tei:correspAction)]" priority="1"/>

    <xsl:template match="tei:editor">
        <xsl:element name="editor">
            <xsl:attribute name="json:array">true</xsl:attribute>
            <xsl:choose>
                <xsl:when test="not(tei:email)">
                    <xsl:apply-templates select="text()"/>
                    <email xmlns="http://www.tei-c.org/ns/1.0">no-email-provided@correspsearch.net</email>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="(text()|tei:email)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:publisher">
        <xsl:element name="publisher">
            <xsl:attribute name="json:array">true</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:idno[@type='url']">
        <xsl:variable name="url">
            <xsl:value-of select="replace(./text(), 'tei-xml', 'tei-json')"/>
        </xsl:variable>
        <idno xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="$url"/></idno>
    </xsl:template>
    
    <xsl:template match="tei:relatedItem/@target">
        <xsl:variable name="url">
            <xsl:value-of select="replace(., 'tei-xml', 'tei-json')"/>
        </xsl:variable>
        <xsl:attribute name="target"><xsl:value-of select="$url"/></xsl:attribute>
    </xsl:template>
    
    <xsl:template match="tei:licence">
        <xsl:element name="licence">
            <xsl:attribute name="target">
                <xsl:value-of select="@target"/>
            </xsl:attribute>
            <xsl:attribute name="json:array">true</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:bibl">
        <xsl:element name="bibl">
            <xsl:attribute name="xml:id">
                <xsl:choose>
                    <xsl:when test="not(@xml:id)">
                        <xsl:value-of select="$generated-uuid"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@xml:id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:attribute name="json:array">true</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:correspDesc[@source]">
        <xsl:element name="correspDesc">
            <xsl:if test="@key">
            <xsl:attribute name="key">
                <xsl:value-of select="@key"/>
            </xsl:attribute>
            </xsl:if>
            <xsl:if test="@ref">
                <xsl:attribute name="ref">
                <xsl:value-of select="@ref"/>
            </xsl:attribute>
            </xsl:if>
                <xsl:attribute name="source">
                    <xsl:choose>
                        <xsl:when test="not(matches(@source, '#'))">
                            <xsl:value-of select="concat('#', @source)"/>        
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@source"/>
                        </xsl:otherwise>
                    </xsl:choose>                    
                </xsl:attribute>
            <xsl:attribute name="json:array">true</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:correspAction">
        <xsl:element name="correspAction">
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:attribute name="json:array">true</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:persName">
        <xsl:element name="persName">
            <xsl:call-template name="ref"/>
            <xsl:attribute name="json:array">true</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:orgName">
        <xsl:element name="orgName">
            <xsl:call-template name="ref"/>
            <xsl:attribute name="json:array">true</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:placeName">
        <xsl:element name="placeName">
            <xsl:call-template name="ref"/>
            <xsl:attribute name="json:array">true</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:correspAction/tei:date" priority="1">
        <xsl:element name="date">
            <xsl:choose>
                <xsl:when test="./@when and ./@from">
                    <xsl:copy-of select="(@from|@to)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="@*"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="json:array">true</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="ref">
            <xsl:attribute name="ref">
                <xsl:value-of select="@ref"/>
            </xsl:attribute>
    </xsl:template>

</xsl:stylesheet>