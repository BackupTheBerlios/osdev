<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- $Id: xbel.xsl,v 1.1 2002/07/02 07:43:39 zhware Exp $ -->

<xsl:output encoding="utf-8" method="html" omit-xml-declaration="yes" indent="yes"/>
<xsl:output doctype-public="-//W3C//DTD XHTML 1.0//EN"/>

<xsl:include href="../config.xsl"/>

<xsl:template match="/xbel">
<xsl:variable name="xml.url">
<xsl:value-of select="concat(@id,'.xml')"/>
</xsl:variable>
<xsl:variable name="txt.url">
<xsl:value-of select="concat(@id,'.txt')"/>
</xsl:variable>
<html>
<head>
<link rel="stylesheet" type="text/css">
<xsl:attribute name="href">
<xsl:value-of select="$html.stylesheet"/>
</xsl:attribute>
</link>
<link rel="made">
<xsl:attribute name="href">
<xsl:value-of select="info/metadata/@owner"/>
</xsl:attribute>
</link>
<title><xsl:value-of select="title"/></title>
</head>
<body>

<p class="menu" align="right">
other formats: (
<a class="menulink" href="{$xml.url}">xml</a> |
<a class="menulink" href="{$txt.url}">txt</a>
)
</p>

<p class="dochead">
<h1><xsl:value-of select="/xbel/title"/></h1>
</p>

<xsl:if test="$page.summary != 0">
<p class="chaphead"><h2>Description</h2></p>
<p class="abstract">
<xsl:apply-templates select="/xbel/desc"/>
</p>
</xsl:if>

<xsl:if test="$page.toc != 0">
<p class="tochead"><h2>Contents</h2></p>
<p>
<xsl:for-each select="folder">
<xsl:sort select="title" />
<xsl:call-template name="toc"/>
</xsl:for-each>
</p>
</xsl:if>

<xsl:for-each select="folder">
<xsl:sort select="title" />
<xsl:call-template name="xbel-folder"/>
</xsl:for-each>
</body>
</html>
</xsl:template>

<xsl:template name="toc">
<xsl:variable name="foldid">
<xsl:choose>
<xsl:when test="@id">
<xsl:value-of select="@id"/>
</xsl:when>
<xsl:otherwise>
folder<xsl:number/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:value-of select="position()"/>. <a class="altlink" href="#{$foldid}"><xsl:value-of select="title"/></a>
<br/>
<xsl:call-template name="NewLine"/>
</xsl:template>

<xsl:template name="xbel-folder">
<xsl:variable name="foldid">
<xsl:choose>
<xsl:when test="@id">
<xsl:value-of select="@id"/>
</xsl:when>
<xsl:otherwise>
folder<xsl:number/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<p class="chaphead"><h2><a name="{$foldid}"><xsl:value-of select="position()"/>.</a> <xsl:value-of select="title"/></h2></p>
<xsl:if test="folder">
<xsl:for-each select = "folder">
<xsl:sort select="title" />
<xsl:call-template name="folder"/>
</xsl:for-each>
</xsl:if>
<xsl:if test="bookmark">
<xsl:for-each select = "bookmark">
<xsl:sort select="title" />
<xsl:call-template name="bookmark"/>
</xsl:for-each>
</xsl:if>
</xsl:template>

<xsl:template name="folder">
<blockquote>
<h3><xsl:value-of select="title"/></h3>
<xsl:if test="folder">
<xsl:for-each select = "folder">
<xsl:sort select="title" />
<xsl:call-template name="folder"/>
</xsl:for-each>
</xsl:if>
<xsl:if test="bookmark">
<xsl:for-each select = "bookmark">
<xsl:sort select="title" />
<xsl:call-template name="bookmark"/>
</xsl:for-each>
</xsl:if>
</blockquote>
</xsl:template>

<xsl:template name="bookmark">
<div class="bookmark">
<a>
<xsl:attribute name="href">
<xsl:value-of select="@href" />
</xsl:attribute>
<xsl:attribute name="visited">
<xsl:value-of select="@visited" />
</xsl:attribute>
<xsl:attribute name="modified">
<xsl:value-of select="@modified" />
</xsl:attribute>
<xsl:value-of select="title" />
</a>
<xsl:call-template name="desc"/>
</div>
</xsl:template>

<xsl:template name="desc">
<xsl:if test="desc !=''">
 -- <xsl:apply-templates select="desc"/>
</xsl:if>
</xsl:template>

<xsl:template name="NewLine">
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="comment">
<font class="comment"><xsl:apply-templates /></font>
</xsl:template>

<xsl:template match="i">
<font class="input"><xsl:apply-templates /></font>
</xsl:template>

<xsl:template match="b">
<b><xsl:apply-templates /></b>
</xsl:template>

<xsl:template match="brite">
<font color="#ff0000"><b><xsl:apply-templates /></b></font>
</xsl:template>

<xsl:template match="c">
<font class="code"><xsl:apply-templates /></font>
</xsl:template>

<xsl:template match="br"><br/></xsl:template>

<xsl:template match="new"><font color="#ff0000"><b>[new!]</b></font>
</xsl:template>

<xsl:template match="uri">
<!-- expand templates to handle things like <uri link="http://bar"><c>foo</c></uri> -->
<xsl:choose>
<xsl:when test="@link">
<a href="{@link}"><xsl:apply-templates /></a>
</xsl:when>
<xsl:otherwise>
<xsl:variable name="loc" select="."/>
<a href="{$loc}"><xsl:apply-templates /></a>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

</xsl:stylesheet>
