<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- $Id: rtf.xsl,v 1.1 2002/07/02 07:43:39 zhware Exp $ -->
<xsl:preserve-space elements="pre"/>
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:include href="../config.xsl"/>
<xsl:template match="/guide">{\rtf1\ansi\ansicpg1252
\deff2\deflang2057
{\fonttbl
{\f0\fswiss\fcharset0 Arial;}
{\f1\fmodern\fcharset0 Courier New;}
{\f2\froman\fcharset0 Times New Roman;}
{\f4\fsymbol\fcharset0 Symbol;}
}
{\stylesheet
{\s0\ql\f2\fs24 Normal;}
{\s1\f0\fs32\b\sb720\sbasedon0 Heading 1;}
{\s2\f1\sbasedon0 Code;}
{\s3\b\i\sbasedon0 Caption;}
{\s4\sbasedon0\lin720\fi-720\tx720 Bulleted;}
{\s5\sbasedon0\lin720\fi-720\tx720 Numbered;}
{\s6\sb120\sa120 Body Text;}
}

\s0\ql\fs24
<xsl:if test="$page.summary != 0">
<xsl:if test="/guide/@link != 'changelog'">
{\s1\f0\fs32\b\sb720 Executive Summary\par}
<xsl:apply-templates select="/guide/abstract"/>\par
</xsl:if>
</xsl:if>

<xsl:if test="$page.toc != 0">
<xsl:if test="/guide/@link != 'changelog'">
{\s1\f0\fs32\b\sb720 Contents\par}
{
<xsl:apply-templates select="chapter" mode="TOC"/>
\par }
</xsl:if>
</xsl:if>
<xsl:apply-templates select="chapter" mode="BODY"/>
<xsl:apply-templates select="/guide/copyright"/>

}
</xsl:template>

<xsl:template match="abstract|author|date|version">
<xsl:apply-templates/>
\par
</xsl:template>

<!-- Suppress the keywords in the main body of the document -->
<xsl:template match="keywordset"/>

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
\par
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
{\page\s1\f0\fs32\b\sb720 <xsl:number/>. <xsl:value-of select="title"/>\par}
</xsl:when>
<xsl:otherwise>
<xsl:if test="/guide/@link != 'changelog'">
{\s1\f0\fs32\b\sb720 <xsl:number/>.\par}
</xsl:if>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="section">
<xsl:with-param name="chapid" value="$chapid"/>
</xsl:apply-templates>
</xsl:template>

<xsl:template match="chapter" mode="TOC">
<xsl:variable name="chapid">
<xsl:choose>
<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
<xsl:otherwise>doc_chap<xsl:number/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:number/>. { <xsl:value-of select="title"/>\par }
</xsl:template>

<xsl:template match="section">
<xsl:param name="chapid"/>
<xsl:if test="title">
<xsl:variable name="sectid"><xsl:value-of select="$chapid"/>_sect<xsl:number/></xsl:variable>
{\s1\f0\fs32\b\sb720 <xsl:value-of select="title"/>\par}
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

<xsl:template match="br">\par</xsl:template>

<xsl:template match="new">{\c1\b [new!]}
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
{\b <xsl:apply-templates />}
</xsl:template>

<xsl:template match="brite">
<font color="#ff0000"><b><xsl:apply-templates /></b></font>
</xsl:template>

<xsl:template match="body">
<xsl:apply-templates />
</xsl:template>

<xsl:template match="c">
{\f1 <xsl:apply-templates />}
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
{\s3\f2\b\i Code listing <xsl:value-of select="$prenum"/>: <xsl:value-of select="@caption" />\par}
</xsl:when>
<xsl:otherwise>
{\s3\f2\b\i Code listing <xsl:value-of select="$prenum"/>\par}
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:if test="$code.caption != 0">
<xsl:choose>
<xsl:when test="@link">
<xsl:value-of select="$pre.caption" />
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$pre.caption" />
</xsl:otherwise>
</xsl:choose>
</xsl:if>
{\pard\s2\f1\lin720\rin720
<xsl:apply-templates /> 
}
</xsl:template>

<xsl:template match="path">
{\f1 <xsl:value-of select="."/>}
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
{\s6\sb120\sa120 <xsl:apply-templates />\par}
</xsl:template>

<xsl:template match="e">
{\i <xsl:apply-templates />}
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

<xsl:template match="ti">
<td class="tableinfo"><xsl:apply-templates /></td>
</xsl:template>

<xsl:template match="th">
<th class="infohead"><b><xsl:apply-templates /></b></th>
</xsl:template>

<xsl:template match="ul">
\par{\pard\s4\lin720\fi-720\tx720
<xsl:apply-templates />
}
</xsl:template>

<xsl:template match="ol">
\par{\s5
<xsl:apply-templates />
}
</xsl:template>

<xsl:template match="li">
{{\f4\'b7}\tab <xsl:apply-templates />\par}
</xsl:template>

</xsl:stylesheet>
