<?xml version="1.0" encoding="utf-8"?>
<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" class="in-text" default-locale="en-US">
  <info>
    <title>Custom IEEE-like style for thesis</title>
    <id>https://example.com/custom-ieee-thesis</id>
    <updated>2026-07-15T00:00:00+00:00</updated>
  </info>

  <!-- In-text citation: [1], [2,3], etc. -->
  <citation collapse="citation-number" after-collapse-delimiter=",">
    <sort>
      <key variable="citation-number" />
    </sort>
    <layout delimiter=",">
      <text variable="citation-number" prefix="[" suffix="]" />
      <text variable="locator" />
    </layout>
  </citation>

  <!-- Bibliography list -->
  <bibliography entry-spacing="1" second-field-align="flush">
    <sort>
      <key variable="citation-number" />
    </sort>
    <layout>
      <!-- [N] numbering -->
      <text variable="citation-number" prefix="[" suffix="]" />

      <!-- Main content group: comma-delimited, ends with period -->
      <group delimiter=", " suffix=".">
        <!-- Authors: Name1, Name2, and Name3 -->
        <names variable="author">
          <name delimiter=", " and="text" />
        </names>

        <!-- Title: upright, in double quotes -->
        <text variable="title" quotes="true" />

        <!-- Container title (booktitle/proceedings): ITALIC -->
        <text variable="container-title" font-style="italic" />

        <!-- Event / conference name: upright (try both CSL variable names) -->
        <text variable="event-title" />
        <text variable="event" />

        <!-- Year -->
        <date variable="issued">
          <date-part name="year" />
        </date>

        <!-- Pages: upright, "pp" prefix -->
        <text variable="page" prefix="pp " />

        <!-- Volume: "Volume N" -->
        <text variable="volume" prefix="Volume " />
      </group>

      <!-- [Online]. Available: URL -->
      <text variable="URL" prefix=" [Online]. Available: " />
    </layout>
  </bibliography>
</style>