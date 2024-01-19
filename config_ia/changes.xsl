<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:ns2="stoopid fake namespace"
    xmlns="urn:isbn:1-931666-22-9" 
    exclude-result-prefixes="ead xsi xs">
    
    <!-- you don't need an output element, but you can use one in case you want to override the default 
        behavior of your XSLT processor -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <!-- standard identity template, which will copy over the full contents of the XML file -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Most issues fixed below are identified when batch-validating bulk EAD exports from ASpace -->
    
    <!-- new rule, which will replace 'library of congress name authority file' with 'lcnaf'
        in any source attributes -->
    <xsl:template match="@source">
        <xsl:attribute name="source">
            <xsl:choose>
                <xsl:when test="contains(., 'library of congress name authority file')">
                    <xsl:value-of select="'lcnaf'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <!-- new rule, which will replace 'Library of Congress Subject Headings' with 'lcsh'
        in any source attributes -->
    <xsl:template match="@source">
        <xsl:attribute name="source">
            <xsl:choose>
                <xsl:when test="contains(., 'Library of Congress Subject Headings')">
                    <xsl:value-of select="'lcsh'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

   <!-- new rule, which will replace 'onrequest' with 'onRequest'
        in any source attributes -->
    <xsl:template match="@xlink:actuate">
        <xsl:attribute name="xlink:actuate">
            <xsl:choose>
                <xsl:when test="contains(., 'onrequest')">
                    <xsl:value-of select="'onRequest'"/>
                </xsl:when>
                <xsl:when test="contains(., 'onload')">
                    <xsl:value-of select="'onLoad'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <!-- new rule, which will replace 'simple' with ''
        in any source attributes -->
    <xsl:template match="@linktype">
        <xsl:attribute name="linktype">
            <xsl:choose>
                <xsl:when test="contains(., 'simple')">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="@target[parent::ead:ref]">
        <xsl:attribute name="xlink:target">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
 
    <!--========== XLINK ==========-->
    
    <xsl:template match="@href[parent::ead:extref]|@href[parent::ead:archref]|@href[parent::ead:ref]|@href[parent::ead:bibref]">
        <xsl:attribute name="xlink:href">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@title[parent::ead:extref]|@title[parent::ead:archref]|@title[parent::ead:ref]|@title[parent::ead:bibref]">
        <xsl:attribute name="xlink:title">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@linktype[parent::ead:extref]|@linktype[parent::ead:archref]|@linktype[parent::ead:ref]|@linktype[parent::ead:bibref]">
        <xsl:attribute name="xlink:type">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@show[parent::ead:extref]|@show[parent::ead:archref]|@show[parent::ead:ref]|@show[parent::ead:bibref]">
        <xsl:attribute name="xlink:show">
            <xsl:choose>
                <!--EAD's showother and shownone do not exist in xlink-->
                <xsl:when test=".='new'">new</xsl:when>
                <xsl:when test=".='replace'">replace</xsl:when>
                <xsl:when test=".='embed'">embed</xsl:when>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@actuate[parent::ead:extref]|@actuate[parent::ead:archref]|@actuate[parent::ead:ref]|@actuate[parent::ead:bibref]">
        <xsl:attribute name="xlink:actuate">
            <xsl:choose>
                <!--EAD's actuateother and actuatenone do not exist in xlink-->
                <xsl:when test=".='onload'">onLoad</xsl:when>
                <xsl:when test=".='onrequest'">onRequest</xsl:when>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <!--========== END XLINK ==========-->
    
    <!-- Remove attributes altogether? -->
    <xsl:template match="@type[parent::ead:extref]|@type[parent::ead:archref]|@type[parent::ead:ref]|@type[parent::ead:bibref]"/>
    <xsl:template match="@actuate[parent::ead:extref]|@actuate[parent::ead:archref]|@actuate[parent::ead:ref]|@actuate[parent::ead:bibref]"/>
    <xsl:template match="@xlink:audience[parent::ead:dao]"/>
    
    <!--Remove <dao> when xlink:href contains [path] -->
    <xsl:template match="ead:dao[@xlink:href='[path]']"/>
    
    <!-- Remove empty note (without <p> subnote or <list> subnote) -->
    <xsl:template match="//ead:scopecontent[not(ead:p or ead:list)]"/>
    <xsl:template match="//ead:odd[not(ead:p or ead:list)]"/>
    <xsl:template match="//ead:arrangement[not(ead:p or ead:list)]"/>
    <xsl:template match="//ead:accessrestrict[not(ead:p or ead:list)]"/>
    
    <!-- Fixes occurences of "Missing Title" supplied in AT-AS migration for all bioghist/chronlist/head elements -->
    <xsl:template match="//ead:chronlist/ead:head">
        <xsl:choose>
            <xsl:when test="contains(.,'Missing Title')">
                <xsl:element name="head">Chronology</xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="head">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Removes <head> element when <list><head>Missing Title</head>.  A byproduce of AT to AS migraiton -->
    <xsl:template match="//ead:list/ead:head"/>
    
</xsl:stylesheet>
