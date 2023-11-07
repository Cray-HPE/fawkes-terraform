<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes"
               indent="yes"/>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  %{~ if disable_spice ~}
  <xsl:template match="/domain/devices/graphics"/>
  %{~ endif ~}
  <xsl:template match="/domain/devices">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
        %{~ for item in pci_data ~}
        <hostdev mode='subsystem'
                  type='pci'
                  managed='yes'>
          <driver name='vfio'/>
            <source>
              <address type="pci"
                        domain="${item.domain}"
                        bus="${item.bus}"
                        slot="${item.slot}"
                        function="${item.function}"/>
            </source>
        </hostdev>
        %{~ endfor ~}
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
