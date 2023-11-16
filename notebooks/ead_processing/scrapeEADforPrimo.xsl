<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:variable name="elements-to-delete" select="('filedesc', 'profiledesc', 'repository', 'physloc', 'head', 'accessrestrict', 'userestrict', 'extent', 'arrangement', 'dao', 'prefercite', 'acqinfo', 'processinfo', 'container')"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[name() = $elements-to-delete]"/>
    
    <xsl:template match="ns1:p" xmlns:ns1="urn:isbn:1-931666-22-9">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="ns1:emph" xmlns:ns1="urn:isbn:1-931666-22-9">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="//unittitle">
        <xsl:choose>
            <xsl:when test=".='Oversize photograph'"/>
            <xsl:when test=".='Oversize photographs'"/>
            <xsl:when test=".='Oversize clipping'"/>
            <xsl:when test=".='Oversize clippings'"/>
            <xsl:when test=".='Negative'"/>
            <xsl:when test=".='Correspondence'"/>
            <xsl:when test=".='Negatives'"/>
            <xsl:when test=".='negatives'"/>
            <xsl:when test=".='Color negative'"/>
            <xsl:when test=".='Color negatives'"/>
            <xsl:when test=".='Black and white print'"/>
            <xsl:when test=".='Black and white prints'"/>
            <xsl:when test=".='Black and white prints,'"/>
            <xsl:when test=".='Black-and-white photographs'"/>
            <xsl:when test=".='Black-and-white photograph'"/>
            <xsl:when test=".='Contact print'"/>
            <xsl:when test=".='Contact prints'"/>
            <xsl:when test=".='Contact Prints'"/>
            <xsl:when test=".='Contact prints,'"/>
            <xsl:when test=".='Transparencies'"/>
            <xsl:when test=".='Transparency'"/>
            <xsl:when test=".='Other photographic formats'"/>
            <xsl:when test=".='Color slides'"/>
            <xsl:when test=".='Color photograph'"/>
            <xsl:when test=".='Color photographs'"/>
            <xsl:when test=".='Color transparencies'"/>
            <xsl:when test=".='Clipping'"/>
            <xsl:when test=".='Clippings'"/>
            <xsl:when test=".='Slides'"/>
            <xsl:when test=".='Oversize'"/>
            <xsl:when test=".='Oversize box'"/>
            <xsl:when test=".='Oversize boxes'"/>
            <xsl:when test=".='Oversize roll'"/>
            <xsl:when test=".='Oversize rolls'"/>
            <xsl:when test=".='4x5 transparencies'"/>
            <xsl:when test=".='4x5 transparency'"/>
            <xsl:when test=".='Papers'"/>
            <xsl:when test=".='Assorted'"/>
            <xsl:when test=".='Assorted unidentified slides,'"/>
            <xsl:when test=".='Assorted unidentified slides'"/>
            <xsl:when test=".='Assorted unidentified photographs,'"/>
            <xsl:when test=".='Assorted unidentified papers,'"/>
            <xsl:when test=".='Assorted papers,'"/>
            <xsl:when test=".='Assorted clippings'"/>
            <xsl:when test=".='Ephemera'"/>
            <xsl:when test=".='Unidentified,'"/>
            <xsl:when test=".='General'"/>
            <xsl:when test=".='Catalog'"/>
            <xsl:when test=".='Posters'"/>
            <xsl:when test=".='Prints'"/>
            <xsl:when test=".='Interviews'"/>
            <xsl:when test=".='Invoices'"/>
            <xsl:when test=".='Flatfile'"/>
            <xsl:otherwise>
                <unittitle>
                    <xsl:value-of select="."/>
                </unittitle>
            </xsl:otherwise>
        </xsl:choose>  
    </xsl:template>
    
    <xsl:template match="//@id" />
    <xsl:template match="//@level" />
    <xsl:template match="//@type" />
    <xsl:template match="//@era" />
    <xsl:template match="//@calendar" />
    <xsl:template match="//@actuate" />
    <xsl:template match="//@href" />
    <xsl:template match="//@show" />
    <xsl:template match="//@linktype" />
    <xsl:template match="//@source" />
    <xsl:template match="//@rules" />
    <xsl:template match="//@role" />
    <xsl:template match="//@altrender" />
    <xsl:template match="//@render" />
    <xsl:template match="//@datechar" />
    <xsl:template match="//@normal" />
    
    <xsl:strip-space elements="*" />
    <xsl:output method="xml" indent="no" encoding="UTF-8"/>
    
</xsl:stylesheet>
