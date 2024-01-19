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
    
    <!--========== XLINK ==========-->

    <xsl:template match="@target[parent::ead:ref]">
        <xsl:attribute name="xlink:target">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
        
    <!--========== END XLINK ==========-->
    
</xsl:stylesheet>
