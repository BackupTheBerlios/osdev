<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="utf-8" method="xml" indent="yes"/>
<xsl:output doctype-system="../dtd/guide.dtd"/>
<!-- $Id: cvs.xsl,v 1.1 2002/07/02 07:43:39 zhware Exp $ -->

<xsl:include href="../config.xsl"/>

<xsl:template match="/changelog">
<guide link="changelog">
<title>OS XML Changelog</title>
<author title="script">cvs.xsl</author>
<abstract>
This page contains a daily Changelog, listing all modifications made to our
CVS tree.
</abstract>
<version>$Revision: 1.1 $</version>
<date><xsl:value-of select="entry/date"/></date>
<chapter>
<xsl:apply-templates select="entry"/>
</chapter>
</guide>
</xsl:template>

<xsl:template match="entry">
<section>
<title>Files modified by <xsl:value-of select="author"/> at 
<xsl:value-of select="date"/>, <xsl:value-of select="time"/>
</title>
<body>
<note><xsl:value-of select="msg"/></note>
<ul>
<xsl:apply-templates select="file"/>
</ul>
</body>
</section>
</xsl:template>

<xsl:template match="file">
<li><path><xsl:value-of select="name"/></path>, <xsl:value-of select="revision"/></li>
</xsl:template>

</xsl:stylesheet>
