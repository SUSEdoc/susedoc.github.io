<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:date="http://exslt.org/dates-and-times"
  extension-element-prefixes="date"
  exclude-result-prefixes="date">
  <xsl:output method="html" omit-xml-declaration="yes"/>
  <!-- Destroys our *wonderfully* arranged buttons to select the document
  format by inserting spaces between them. -->
  <!--<xsl:output method="xml" indent="yes"/>-->

  <xsl:key name="categories" match="/indexconfig/doc" use="@cat"/>

  <xsl:variable name="baseurl" select="/indexconfig/meta/baseurl"/>
  <xsl:variable name="variants" select="/indexconfig/meta/variants"/>

  <xsl:template match="/indexconfig">
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text><xsl:text>&#10;</xsl:text>
    <html>
      <head>
        <meta charset="utf-8"/>
        <xsl:apply-templates select="meta/title"/>
        <xsl:apply-templates select="meta/style"/>
      </head>
      <body>
        <nav class="tabwrap">
          <div class="tabs">
            <xsl:apply-templates select="meta/tabs"/>
            <a href="#"></a>
          </div>
        </nav>
        <xsl:apply-templates select="meta/head"/>
        <xsl:apply-templates select="meta/desc"/>
        <ul>
          <xsl:apply-templates select="cats/cat" mode="overview"/>
        </ul>
        <div class="topmargin"></div>
        <xsl:apply-templates select="cats"/>
        <div class="topmargin"></div>
        <xsl:apply-templates select="meta/bottominfo"/>
        <p>Build time for this overview page: <xsl:value-of select="date:date-time()"/></p>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="@*|node()"/>
  <xsl:template match="@*|node()" mode="copy">
    <xsl:copy><xsl:apply-templates select="@*|node()" mode="copy"/></xsl:copy>
  </xsl:template>

  <xsl:template match="title">
    <title><xsl:value-of select="."/></title>
  </xsl:template>
  <xsl:template match="style">
    <link rel="stylesheet">
      <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
    </link>
  </xsl:template>
  <xsl:template match="head">
    <h1><xsl:apply-templates select="node()" mode="copy"/></h1>
  </xsl:template>
  <xsl:template match="tabs|desc|bottominfo">
    <xsl:apply-templates select="node()" mode="copy"/>
  </xsl:template>
  <xsl:template match="cats">
    <xsl:apply-templates select="cat"/>
  </xsl:template>
  <xsl:template match="cat">
    <xsl:variable name="node" select="."/>
    <xsl:variable name="catnode" select="key('categories', $node/@id)"/>

    <xsl:if test="$catnode">
      <h2 id="{@id}"><xsl:apply-templates select="node()" mode="copy"/></h2>
      <ul class="doclist">
        <xsl:apply-templates select="$catnode">
          <xsl:sort lang="en" select="."/>
        </xsl:apply-templates>
      </ul>
      <hr/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cat" mode="overview">
    <xsl:variable name="node" select="."/>
    <xsl:if test="key('categories', @id)">
      <li><a href="#{@id}"><xsl:value-of select="."/></a></li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="doc">
    <xsl:variable name="cat" select="@cat"/>
    <xsl:variable name="urlstart">
      <xsl:if test="$baseurl != ''">
        <xsl:value-of select="$baseurl"/>
        <xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:value-of select="/indexconfig/cats/cat[@id = $cat]/@repo"/>
    </xsl:variable>
    <li>
      <span>
        <xsl:value-of select="."/>
      </span>
      <xsl:call-template name="prepare-links">
        <xsl:with-param name="urlstart" select="$urlstart"/>
        <xsl:with-param name="doc" select="@doc"/>
        <xsl:with-param name="branches" select="concat(normalize-space(@branches), ' ')"/>
      </xsl:call-template>
    </li>
  </xsl:template>

  <xsl:template name="prepare-links">
    <xsl:param name="urlstart" select="''"/>
    <xsl:param name="doc" select="''"/>
    <xsl:param name="branches" select="''"/>
    <xsl:param name="branch" select="substring-before($branches, ' ')"/>

    <xsl:if test="$branch != '' and $branch != ' '">
      <span class="branch">
        <span class="branchname"><xsl:value-of select="$branch"/></span>
        <xsl:call-template name="generate-links">
          <xsl:with-param name="url" select="concat($urlstart, '/', $branch, '/', $doc)"/>
        </xsl:call-template>
      </span>
      <xsl:call-template name="prepare-links">
        <xsl:with-param name="urlstart" select="$urlstart"/>
        <xsl:with-param name="doc" select="$doc"/>
        <xsl:with-param name="branches" select="substring-after($branches, ' ')"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="generate-links">
    <xsl:param name="url" select="''"/>
    <xsl:param name="context" select="/indexconfig/meta/variants/variant[1]"/>
    <xsl:variable name="variant-dir" select="$context/@dir"/>
    <xsl:variable name="variant-name" select="$context/text()"/>
    <a href="{$url}/{$variant-dir}"><xsl:value-of select="$variant-name"/></a>
    <xsl:if test="$context/following-sibling::variant[1]">
      <xsl:call-template name="generate-links">
        <xsl:with-param name="url" select="$url"/>
        <xsl:with-param name="context" select="$context/following-sibling::variant[1]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

