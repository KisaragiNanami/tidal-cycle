<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:atom="http://www.w3.org/2005/Atom">
<xsl:output method="html" encoding="UTF-8" indent="yes"/>

<xsl:template match="/">
  <html>
    <head>
      <title><xsl:value-of select="/rss/channel/title"/></title>
      <link rel="stylesheet" type="text/css" href="/rss.css" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    </head>
    <body>
      <div class="rss-container">
        <header class="rss-header">
          <div class="header-content">
            <div class="header-text">
              <h1><a href="{/rss/channel/link}" target="_blank"><xsl:value-of select="/rss/channel/title"/></a></h1>
              <p><xsl:value-of select="/rss/channel/description"/></p>
            </div>
            <div class="subscribe-area">
              <a href="https://app.follow.is/share/feeds/62534251890534400" class="subscribe-button folo" target="_blank">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><g fill="none" fill-rule="evenodd"><path d="m12.594 23.258l-.012.002l-.071.035l-.02.004l-.014-.004l-.071-.036q-.016-.004-.024.006l-.004.01l-.017.428l.005.02l.01.013l.104.074l.015.004l.012-.004l.104-.074l.012-.016l.004-.017l-.017-.427q-.004-.016-.016-.018m.264-.113l-.014.002l-.184.093l-.01.01l-.003.011l.018.43l.005.012l.008.008l.201.092q.019.005.029-.008l.004-.014l-.034-.614q-.005-.019-.02-.022m-.715.002a.02.02 0 0 0-.027.006l-.006.014l-.034.614q.001.018.017.024l.015-.002l.201-.093l.01-.008l.003-.011l.018-.43l-.003-.012l-.01-.01z"/><path fill="currentColor" d="M17 3a4 4 0 0 1 3.995 3.8L21 7v10a4 4 0 0 1-3.8 3.995L17 21H7a4 4 0 0 1-3.995-3.8L3 17V7a4 4 0 0 1 3.8-3.995L7 3zm-5.5 12a1.5 1.5 0 1 0 0 3a1.5 1.5 0 0 0 0-3m1-4.5h-4a1.5 1.5 0 0 0-.144 2.993l.144.007h4a1.5 1.5 0 0 0 .144-2.993zm3-4.5h-6a1.5 1.5 0 1 0 0 3h6a1.5 1.5 0 0 0 0-3"/></g></svg>
                在 Folo 订阅
              </a>
            </div>
          </div>
        </header>

        <div class="rss-items">
          <xsl:for-each select="/rss/channel/item">
            <article class="rss-item">
              <h2>
                <a href="{link}" target="_blank" rel="noopener noreferrer">
                  <xsl:value-of select="title"/>
                </a>
              </h2>
              <p class="meta">
                发布于: <xsl:value-of select="pubDate"/>
              </p>
              <div class="description">
                <xsl:value-of select="description" disable-output-escaping="yes"/>
              </div>
            </article>
          </xsl:for-each>
        </div>

        <footer class="rss-footer">
          <p>此 RSS Feed 使用 XSLT 进行了样式化，以提供更好的浏览器阅读体验。</p>
        </footer>
      </div>
    </body>
  </html>
</xsl:template>

</xsl:stylesheet>