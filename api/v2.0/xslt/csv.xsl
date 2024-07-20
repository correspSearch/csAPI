<!-- 
    The MIT License (MIT)

Copyright (c) 2015 Klaus Rettinghaus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Improved by Stefan Dumont, 2016

--><!-- * cmi2csv * --><!-- version 1.0 --><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.bbaw.de/telota/correspSearch" xmlns:tei="http://www.tei-c.org/ns/1.0" version="2.0" exclude-result-prefixes="tei cs">
    <xsl:output encoding="UTF-8" method="text" media-type="csv" indent="no"/>
    <xsl:variable name="delimiter">
        <xsl:text>;</xsl:text>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:text>"sender"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>"senderID"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>"senderPlace"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>"senderPlaceID"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>"senderDate"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>"addressee"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>"addresseeID"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>"addresseePlace"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>"addresseePlaceID"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>"addresseeDate"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>"edition"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>"key"</xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:for-each select="//tei:correspDesc">
            <xsl:variable name="biblref">
                <xsl:value-of select="substring-after(@source,'#')"/>
            </xsl:variable>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="tei:correspAction[@type='sent']/tei:persName"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="tei:correspAction[@type='sent']/tei:persName/@ref"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="tei:correspAction[@type='sent']/tei:placeName"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="tei:correspAction[@type='sent']/tei:placeName/@ref"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>"</xsl:text>
            <xsl:if test="tei:correspAction[@type='sent']/tei:date/@cert">
                <xsl:text>[</xsl:text>
            </xsl:if>
            <!-- date fehlt noch from/to -->
            <xsl:value-of select="tei:correspAction[@type='sent']/tei:date/@when"/>
            <xsl:if test="tei:correspAction[@type='sent']/tei:date/@cert">
                <xsl:text>]</xsl:text>
            </xsl:if>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="tei:correspAction[@type='received']/tei:persName"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="tei:correspAction[@type='received']/tei:persName/@ref"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="tei:correspAction[@type='received']/tei:placeName"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="tei:correspAction[@type='received']/tei:placeName/@ref"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>"</xsl:text>
            <xsl:if test="tei:correspAction[@type='received']/tei:date/@cert">
                <xsl:text>[</xsl:text>
            </xsl:if>
            <xsl:value-of select="tei:correspAction[@type='received']/tei:date/@when"/>
            <xsl:if test="tei:correspAction[@type='received']/tei:date/@cert">
                <xsl:text>]</xsl:text>
            </xsl:if>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="ancestor::tei:TEI//tei:sourceDesc/tei:bibl[@xml:id=$biblref]/normalize-space(.)"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="@key"/>
            <xsl:text>"</xsl:text>
            <xsl:text>
</xsl:text>
        </xsl:for-each>
        <xsl:text>
</xsl:text>
        <xsl:text>"Data providers"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>
</xsl:text>
        <xsl:text>"correspSearch API - Correspondence Descriptions from divers sources http://correspSearch.bbaw.de"</xsl:text>
        <xsl:value-of select="$delimiter"/>
        <xsl:text>
</xsl:text>
        <xsl:for-each select="//tei:respStmt/tei:name">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$delimiter"/>
            <xsl:text>
</xsl:text>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>