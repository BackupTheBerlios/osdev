<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- $Id: html.xsl,v 1.1 2002/07/02 07:43:39 zhware Exp $ -->

<xsl:output encoding="utf-8" method="html" omit-xml-declaration="yes" indent="yes"/>
<xsl:output doctype-public="-//W3C//DTD HTML 4.0//EN"/>
<xsl:preserve-space elements="pre"/>

<xsl:include href="../config.xsl"/>

<xsl:template match="/guide">
<xsl:variable name="xml.url">
<xsl:value-of select="concat(@link,'.xml')"/>
</xsl:variable>
<xsl:variable name="txt.url">
<xsl:value-of select="concat(@link,'.txt')"/>
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
<xsl:value-of select="author/mail"/>
</xsl:attribute>
</link>
<title>
<xsl:choose>
   <xsl:when test="subtitle">
      <xsl:value-of select="title"/>: <xsl:value-of select="subtitle"/>
   </xsl:when>
   <xsl:otherwise>
      <xsl:value-of select="title"/>
   </xsl:otherwise>
</xsl:choose>
</title>
<xsl:apply-templates select="/guide/keywordset" mode="info"/>
</head>
<body>

<p class="menu" align="right">
other formats: (
<a class="menulink" href="{$xml.url}">xml</a> |
<a class="menulink" href="{$txt.url}">txt</a>
)
</p>

<p class="dochead">
<h1>
<xsl:choose>
   <xsl:when test="/guide/subtitle">
      <xsl:value-of select="/guide/title"/>: <xsl:value-of select="/guide/subtitle"/>
   </xsl:when>
   <xsl:otherwise>
      <xsl:value-of select="/guide/title"/>
   </xsl:otherwise>
</xsl:choose>
</h1>
</p>
<p>
<xsl:apply-templates select="author"/><br/>
<xsl:apply-templates select="date"/>
<xsl:apply-templates select="version"/>
</p>

<xsl:if test="$page.summary != 0">
<xsl:if test="/guide/@link != 'changelog'">
<p class="chaphead"><h2>Executive Summary</h2></p>
<p class="abstract">
<xsl:apply-templates select="/guide/abstract"/>
</p>
</xsl:if>
</xsl:if>

<xsl:if test="$page.toc != 0">
<xsl:if test="/guide/@link != 'changelog'">
<p class="tochead"><h2>Contents</h2></p>
<p>
<xsl:apply-templates select="chapter" mode="TOC"/>
</p>
</xsl:if>
</xsl:if>
<xsl:apply-templates select="chapter" mode="BODY"/>
<xsl:apply-templates select="/guide/copyright"/>
</body>
</html>
</xsl:template>

<xsl:template match="abstract|author|date|version">
<xsl:apply-templates/>
<br/>
</xsl:template>

<!-- Suppress the keywords in the main body of the document -->
<xsl:template match="keywordset"/>

<!-- But put them into the HTML header. -->
<xsl:template match="keywordset" mode="info">
<meta name="keywords">
<xsl:attribute name="content">
<xsl:apply-templates select="keyword"/>
</xsl:attribute>
</meta>
</xsl:template>

<xsl:template match="keyword">
<xsl:value-of select="."/>
<xsl:if test="position() != last()">
<xsl:text>, </xsl:text>
</xsl:if>
</xsl:template>

<xsl:template match="copyright">
<p>
<div class="copyright"><xsl:apply-templates/></div>
</p>
</xsl:template>
 
<xsl:template match="img">
   <img src="{@src}"/>
</xsl:template>

<xsl:template match="author/homepage">
<br/>
Homepage:
<a class="altlink">
<xsl:attribute name="href">
<xsl:value-of select="."/>
</xsl:attribute>
<xsl:value-of select="."/>
</a>
</xsl:template>

<xsl:template match="mail">
<a href="mailto:{@link}"><xsl:value-of select="."/></a>
</xsl:template>

<xsl:template match="author/mail|author/email">
<a class="altlink">
<xsl:attribute name="href">
<xsl:choose>
<xsl:when test="@link">
<xsl:value-of select="concat('mailto:',@link)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="concat('mailto:',text())"/>
</xsl:otherwise>
</xsl:choose>
</xsl:attribute>
<xsl:value-of select="."/>
</a>
</xsl:template>

<xsl:template match="author/title">
(<i><xsl:value-of select="."/></i>)
</xsl:template>

<xsl:template match="chapter" mode="BODY">
<xsl:variable name="chapid">
<xsl:choose>
<xsl:when test="@id">
<xsl:value-of select="@id"/>
</xsl:when>
<xsl:otherwise>
doc_chap<xsl:number/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:choose>
<xsl:when test="title">
<p class="chaphead"><h2><a name="{$chapid}"><xsl:number/>.</a> <xsl:value-of select="title"/></h2></p>
</xsl:when>
<xsl:otherwise>
<xsl:if test="/guide/@link != 'changelog'">
<p class="chaphead"><h2><a name="{$chapid}"><xsl:number/>.</a></h2></p> 
</xsl:if>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="section">
<xsl:with-param name="chapid" select="$chapid"/>
</xsl:apply-templates>
</xsl:template>

<xsl:template match="chapter" mode="TOC">
<xsl:variable name="chapid">
<xsl:choose>
<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
<xsl:otherwise>doc_chap<xsl:number/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:number/>. <a class="altlink" href="#{$chapid}"><xsl:value-of select="title"/></a>
<br/>
</xsl:template>

<xsl:template match="section">
<xsl:param name="chapid"/>
<xsl:if test="title">
<xsl:variable name="sectid"><xsl:value-of select="$chapid"/>_sect<xsl:number/></xsl:variable>
<p class="secthead"><a name="{$sectid}"><xsl:value-of select="title"/></a></p>
</xsl:if>
<xsl:apply-templates select="body"/>
</xsl:template>

<xsl:template match="figure">
<xsl:variable name="fignum"><xsl:number level="any"/></xsl:variable>
<xsl:variable name="figid">doc_fig<xsl:number/></xsl:variable>
<br/>
<a name="{$figid}"/>
<table cellspacing="0" cellpadding="0" border="0">
<tr><td class="infohead">
<xsl:choose>
<xsl:when test="@caption">
Figure <xsl:value-of select="$fignum"/>: <xsl:value-of select="@caption" />
</xsl:when>
<xsl:otherwise>
Figure <xsl:value-of select="$fignum"/>
</xsl:otherwise>
</xsl:choose>
</td></tr>
<tr><td align="center" class="infogfx">
<xsl:choose>
<xsl:when test="@short">
<img src="{@link}" alt="Fig. {$fignum}: {@short}"/>
</xsl:when>
<xsl:otherwise>
<img src="{@link}" alt="Fig. {$fignum}"/>
</xsl:otherwise>
</xsl:choose>
</td></tr></table>
<br/>
</xsl:template>

<!--figure without a caption; just a graphical element-->
<xsl:template match="fig">
<center>
<xsl:choose>
<xsl:when test="@linkto">
<a href="{@linkto}"><img src="{@link}" alt="{@short}"/></a>
</xsl:when>
<xsl:otherwise>
<img src="{@link}" alt="{@short}"/>
</xsl:otherwise>
</xsl:choose>
</center>
</xsl:template>

<xsl:template match="br"><br/></xsl:template>

<xsl:template match="new"><font color="#ff0000"><b>[new!]</b></font>
</xsl:template>

<xsl:template match="note">
<table class="ncontent" width="80%" align="center" border="0" cellspacing="0" cellpadding="0">
<xsl:if test="@caption">
<tr>
<td class="infohead" align="left">
<xsl:value-of select="@caption" /></td>
</tr>
</xsl:if>
<tr><td class="note">
<xsl:apply-templates />
</td></tr></table>
</xsl:template>

<xsl:template match="impo">
<table class="ncontent" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td class="impotext">
<b>Important: </b><xsl:apply-templates />
</td></tr></table>
</xsl:template>

<xsl:template match="warn">
<table class="ncontent" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td class="warntext">
<b>Warning: </b><xsl:apply-templates />
</td></tr></table>
</xsl:template>

<xsl:template match="codenote">
<font class="comment">// <xsl:value-of select="." /></font>
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

<xsl:template match="body">
<xsl:apply-templates />
</xsl:template>

<xsl:template match="c">
<font class="code"><xsl:apply-templates /></font> 
</xsl:template>

<xsl:template match="box">
<p class="infotext"><xsl:apply-templates /></p>
</xsl:template>

<xsl:template match="pre">
<xsl:variable name="prenum"><xsl:number level="any" /></xsl:variable>
<xsl:variable name="preid">listing<xsl:number level="any" /></xsl:variable>
<xsl:variable name="pre.caption">
<xsl:choose>
<xsl:when test="@caption">
Code listing <xsl:value-of select="$prenum"/>: <xsl:value-of select="@caption" />
</xsl:when>
<xsl:otherwise>
Code listing <xsl:value-of select="$prenum"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<a name="{$preid}"/>
<table width="90%" align="center" cellspacing="0" cellpadding="0" border="0">
<xsl:if test="$code.caption != 0">
<tr><td class="infohead">
<xsl:choose>
<xsl:when test="@link">
<a href="{@link}"><xsl:value-of select="$pre.caption" /></a>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$pre.caption" />
</xsl:otherwise>
</xsl:choose>
</td></tr>
</xsl:if>
<tr><td class="infotext">
<pre> 
<xsl:apply-templates /> 
</pre> 
</td></tr></table> 
</xsl:template>

<xsl:template match="path">
<font class="path"><xsl:value-of select="."/></font>
</xsl:template>

<xsl:template match="email">
<xsl:choose>
<xsl:when test="@link">
<a href="mailto:{@link}"><xsl:apply-templates /></a>
</xsl:when>
<xsl:otherwise>
<xsl:variable name="loc" select="."/>
<a href="mailto:{$loc}"><xsl:apply-templates /></a>
</xsl:otherwise>
</xsl:choose>
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

<xsl:template match="p">
<p><xsl:apply-templates /></p>
</xsl:template>

<xsl:template match="e">
<font class="emphasis"><xsl:apply-templates /></font>
</xsl:template>

<xsl:template match="mail">
<a href="mailto:{@link}"><xsl:value-of select="."/></a>
</xsl:template>

<xsl:template match="table">
<table class="ntable" cellspacing="0" cellpadding="0">
<xsl:apply-templates />
</table>
</xsl:template>

<xsl:template match="tr">
<tr><xsl:apply-templates /></tr>
</xsl:template>

<xsl:template match="td">
<td><xsl:apply-templates /></td>
</xsl:template>

<xsl:template match="ti">
<td class="tableinfo"><xsl:apply-templates /></td>
</xsl:template>

<xsl:template match="th">
<th class="infohead"><b><xsl:apply-templates /></b></th>
</xsl:template>

<xsl:template match="ul">
<ul><xsl:apply-templates /></ul>
</xsl:template>

<xsl:template match="ol">
<ol><xsl:apply-templates /></ol>
</xsl:template>

<xsl:template match="li">
<li><xsl:apply-templates /></li>
</xsl:template>

</xsl:stylesheet>
