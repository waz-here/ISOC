# OFDS Google Fu: Advanced Search Techniques for Discovering Fibre Network Maps

> A practical field guide for Internet Society, NOG, regulator, operator and researcher workshops focused on discovering publicly available terrestrial fibre infrastructure information and converting it into OFDS datasets.

## Introduction

The Open Fibre Data Standard (OFDS) exists because terrestrial fibre infrastructure data is often difficult to discover, inconsistent in format and fragmented across many sources. Publicly available information may exist as PDF brochures, interactive maps, annual reports, wholesale portals, planning documents, KMZ files, GIS datasets, images, regulatory submissions or investor presentations.

Finding these resources is often more challenging than converting them into OFDS.

This guide teaches the practical search and OSINT skills needed to locate fibre maps and infrastructure information using search engines, public repositories, government portals and operator websites.

The goal is not to identify confidential infrastructure information. The goal is to discover and responsibly use information that operators, governments and organisations have already chosen to make publicly available.

---

# Table of Contents

1. What is Google Fu?
2. Understanding Search Engines
3. Core Search Operators
4. Advanced Search Techniques
5. PDF Discovery
6. Image Discovery
7. Government Data Sources
8. Regulatory Data Sources
9. Searching Operator Websites
10. Using Investor Reports
11. Finding PoP Locations
12. GitHub Discovery Techniques
13. Searching for GIS Data
14. Reverse Image Searching
15. Mapping Infrastructure by Inference
16. Australia Case Study
17. Workflow From Search to OFDS
18. Validation Techniques
19. Ethical Considerations
20. Workshop Exercises

# 1. What is Google Fu?

Google Fu refers to the skill of using search engines efficiently to discover information that is difficult to find through normal browsing.

Most fibre operators do not publish pages titled "Fibre Network Map".

Instead, maps are often buried in:

- Marketing brochures
- Investor presentations
- Wholesale documentation
- Product datasheets
- Annual reports
- Regulatory submissions
- Network expansion announcements
- Construction notices

The ability to find these documents is a valuable OFDS skill.

# 2. Understanding Search Engines

Search engines index content differently.

| Search Engine | Best Use |
|---------------|----------|
| Google | General discovery |
| Bing | PDF discovery |
| DuckDuckGo | Alternative coverage |
| GitHub Search | Source files and datasets |
| Google Images | Embedded maps |
| Bing Images | Reverse image matching |
|

Use multiple search engines for important investigations.

# 3. Core Search Operators

## site:

Search a specific website.

```text
site:vocus.com.au network map
```

## filetype:

Search specific file formats.

```text
filetype:pdf fibre network
```

## Quotation Marks

Require an exact phrase.

```text
"network map"
```

## OR

Search alternative terms.

```text
"network map" OR "backbone map"
```

## Minus Operator

Exclude unwanted content.

```text
fibre map -residential -broadband
```

# 4. Advanced Search Techniques

## Search Around Known Terms

Operators frequently use unique terminology.

Try:

```text
"optical network"
```

```text
"national backbone"
```

```text
"transmission network"
```

```text
"intercapital network"
```

## Search Pages Rather Than Files

```text
site:operator.com.au intitle:infrastructure
```

## Search Old Material

```text
site:operator.com.au before:2022 fibre pdf
```

Older maps are often easier to locate.

# 5. PDF Discovery

Many of the best maps are located inside PDFs.

## Generic Search

```text
filetype:pdf "network map"
```

## Operator Search

```text
site:vocus.com.au filetype:pdf
```

```text
site:telstra.com.au filetype:pdf fibre
```

```text
site:superloop.com.au filetype:pdf network
```

## Investor Presentations

```text
operator investor presentation fibre
```

# 6. Image Discovery

Maps are frequently published as images.

Search:

```text
site:operator.com network
```

Then switch to Images.

Useful image formats:

- PNG
- JPG
- SVG
- WEBP

Download the highest resolution available.

# 7. Government Data Sources

Potential sources include:

- Communications regulators
- Infrastructure agencies
- Open data portals
- Planning authorities
- Utility coordination authorities

Search examples:

```text
site:gov.au fibre map
```

```text
site:gov.au telecommunications infrastructure
```

```text
site:gov.au open data fibre
```

# 8. Regulatory Data Sources

Regulators often publish material received from industry.

Search:

```text
site:acma.gov.au telecommunications infrastructure
```

```text
site:acma.gov.au fibre network
```

```text
site:acma.gov.au SIP map
```

# 9. Searching Operator Websites

## Australia Examples

### Telstra

```text
site:telstra.com.au "network map"
```

### Optus

```text
site:optus.com.au backbone network
```

### Vocus

```text
site:vocus.com.au "our network"
```

### Superloop

```text
site:superloop.com fibre
```

### AARNet

```text
site:aarnet.edu.au network map
```

### NBN

```text
site:nbnco.com.au network map
```

# 10. Using Investor Reports

Investor reports frequently contain:

- Backbone maps
- Coverage maps
- PoP locations
- Intercity routes
- Datacentre locations

Search:

```text
operator annual report fibre
```

```text
operator investor presentation network
```

```text
site:asx.com.au operator presentation
```

# 11. Finding PoP Locations

Sometimes route maps do not exist.

PoP locations can provide sufficient information to build an indicative network.

Search terms:

```text
"point of presence"
```

```text
"PoP locations"
```

```text
"datacentre locations"
```

```text
"service locations"
```

# 12. GitHub Discovery Techniques

GitHub contains:

- GeoJSON
- KML
- KMZ
- Shapefiles
- OFDS datasets

Search:

```text
site:github.com OFDS Australia
```

```text
site:github.com fibre geojson
```

```text
site:github.com kml fibre
```

# 13. Searching for GIS Data

## GeoJSON

```text
geojson fibre
```

## KML

```text
fibre kml
```

## KMZ

```text
fibre kmz
```

## Shapefile

```text
fibre shapefile
```

# 14. Reverse Image Searching

Sometimes a map exists but you do not know its source.

Use:

- Google Lens
- Bing Visual Search

This can reveal:

- Original PDF
- Original operator
- Earlier versions
- Higher resolution copies

# 15. Mapping Infrastructure by Inference

Sometimes only PoP locations exist.

Potential public clues include:

- Road corridors
- Rail corridors
- Utility easements
- Transmission corridors
- Public announcements
- Route descriptions

Record assumptions clearly.

# 16. Australia Case Study

Recommended first targets:

1. Vocus
2. AARNet
3. Superloop
4. NBN
5. Telstra
6. Optus

Useful search templates:

```text
site:com.au filetype:pdf ("network map" OR "fibre map")
```

```text
site:com.au "point of presence"
```

```text
site:com.au backbone network pdf
```

# 17. Workflow From Search to OFDS

```text
Search
  ↓
Locate Source Material
  ↓
Download Image/PDF
  ↓
Georeference
  ↓
Trace Routes
  ↓
Export KML
  ↓
Convert to OFDS
  ↓
Validate
  ↓
Publish
```

## Example Toolchain

- Google Search
- Google Images
- Google Earth Pro
- QGIS
- kml2ofds
- GitHub

# 18. Validation Techniques

Cross-check using:

- Multiple maps
- Operator websites
- Datacentre directories
- PeeringDB
- Public presentations
- News articles

Validation improves confidence.

# 19. Ethical Considerations

Always:

- Use publicly available information
- Respect copyright
- Respect terms of use
- Record source URLs
- Document assumptions
- Mark inferred routes clearly

Avoid attempting to access restricted information.

# 20. Workshop Exercises

## Beginner

Locate a public fibre network map from an Australian operator.

## Intermediate

Locate PoP locations for an operator.

## Advanced

Locate a PDF map.
Convert it into a KML.

## Expert

Create an OFDS dataset from a publicly available network map.

# Cheat Sheet

```text
site:vocus.com.au filetype:pdf
site:telstra.com.au network map
site:optus.com.au backbone network
site:aarnet.edu.au fibre map
site:github.com OFDS Australia
site:gov.au fibre map
filetype:pdf fibre network
"point of presence"
"intercapital network"
```

# Conclusion

Good OFDS mapping starts with good discovery. The ability to locate public network information quickly and efficiently is a foundational skill for researchers, operators, regulators, Internet Society chapters and NOG communities. Mastering these search techniques dramatically increases the amount and quality of information available for conversion into OFDS datasets.

## References

- Google Advanced Search: https://www.google.com/advanced_search
- Master the Art of Google Fu with Search Tips & Tricks: https://iocreative.com/blog/master-the-art-of-google-fu-with-search-tips-tricks/
