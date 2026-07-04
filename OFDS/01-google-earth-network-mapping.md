# Lab 01: Mapping Terrestrial Networks with Google Earth Pro

## Purpose

This lab introduces Google Earth Pro as a simple visual mapping tool for terrestrial network infrastructure.

The goal is not to replace GIS tools. The goal is to help network engineers quickly visualise routes, nodes, network sites, physical diversity, and potential exposure to roads, rivers, hills, and other geography.

## Scenario

You are supporting early planning for a small terrestrial network. Your task is to create a simple Google Earth project showing:

- Three network sites
- A possible fibre route between the sites
- A possible backup or diverse route
- Distance measurements
- An elevation profile for at least one path
- A saved KML or KMZ file that could be shared with others

You can use locations from your own country, or the sample locations provided by the instructor.

## Before you start

Install Google Earth Pro for Desktop.

Create a working folder on your computer called:

```text
google-earth-network-lab
```

Save any exported files into this folder.

## Part 1: Open Google Earth Pro and navigate

1. Open Google Earth Pro.
2. Search for your first city, exchange, IXP, data centre, or network location.
3. Practise zooming, rotating, and tilting the view.
4. Turn the Terrain layer on.
5. Return to a top-down view before drawing network paths.

### Discussion

For network mapping, a top-down view is usually better for route drawing and measurement. Tilted views can be useful for understanding terrain, valleys, hills, and line-of-sight issues.

## Part 2: Add network site placemarks

Create at least three placemarks.

Suggested examples:

- Core POP
- Regional exchange
- Cable landing station
- IXP site
- Mobile tower
- Microwave relay site
- Customer aggregation site

For each placemark:

1. Click the placemark icon.
2. Place it at the correct location.
3. Give it a useful name.
4. Add a short description.

Example naming pattern:

```text
POP-01 - Core Site
POP-02 - Regional Exchange
CLS-01 - Cable Landing Station
```

Example description:

```text
Role: Core POP
Status: Existing
Notes: Candidate site for route diversity review
```

## Part 3: Draw a terrestrial fibre route

Create a path between two or more placemarks.

1. Click the path tool.
2. Name the path.
3. Draw the route by following a realistic corridor such as:
   - Road
   - Rail
   - Power easement
   - Existing utility corridor
   - Coastal or inland route
4. Save the path.

Suggested path names:

```text
Route A - Primary Fibre Path
Route B - Alternate Fibre Path
```

### Route review questions

As you draw the path, consider:

- Does the route follow a single road for a long distance?
- Does it cross rivers, bridges, landslide-prone areas, or low-lying coastal sections?
- Are there obvious choke points?
- Is the alternate route genuinely diverse, or does it rejoin the primary route too quickly?
- Would both routes be affected by the same flood, cyclone, fire, bridge failure, or road closure?

## Part 4: Measure path distance

Use the ruler or saved path measurement tools to estimate route distance.

Record the following:

| Route | Approximate distance | Notes |
|---|---:|---|
| Route A - Primary Fibre Path |  |  |
| Route B - Alternate Fibre Path |  |  |

### Important note

Google Earth measurements are useful for planning and discussion, but they should be treated as estimates. They are not a substitute for survey-grade engineering measurements.

## Part 5: View an elevation profile

For one route:

1. Right-click the path.
2. Select **Show Elevation Profile**.
3. Review the profile.
4. Identify any high points, steep changes, valleys, or possible terrain issues.

Record:

| Question | Observation |
|---|---|
| Highest point on the route |  |
| Lowest point on the route |  |
| Any steep sections? |  |
| Any terrain concerns? |  |

### Network engineering use cases

Elevation profiles are useful for:

- Microwave path planning
- Understanding terrain exposure
- Reviewing possible cable routes through hills, valleys, or mountain passes
- Explaining geography to non-technical stakeholders

They do not replace detailed radio planning, Fresnel zone analysis, LiDAR, or engineering survey work.

## Part 6: Save and export the project

Organise your work in the Places panel.

Suggested folder structure:

```text
Network Mapping Lab
├── Sites
│   ├── POP-01 - Core Site
│   ├── POP-02 - Regional Exchange
│   └── CLS-01 - Cable Landing Station
└── Routes
    ├── Route A - Primary Fibre Path
    └── Route B - Alternate Fibre Path
```

Export the folder as:

```text
network-mapping-lab.kmz
```

or

```text
network-mapping-lab.kml
```

Use KMZ when you want a compact package. Use KML when you want a plain text file that can be inspected, edited, or version controlled.

## Wrap-up discussion

Discuss:

- What was easy to map?
- What was difficult to represent?
- Where could the route data be misleading?
- What extra information would improve confidence?
- When would you move from Google Earth to QGIS or another GIS tool?

## Extension activity

Import a KML or KMZ file containing existing infrastructure data and compare it with your manually drawn route.

If working with Open Fibre Data Standard data, a useful workflow is:

1. Prepare or validate OFDS data.
2. Convert the relevant routes and nodes to KML.
3. Import into Google Earth Pro.
4. Use Google Earth for visual review and stakeholder discussion.
5. Use GIS tools for deeper analysis, validation, and spatial joins.


## Checklist

Participants should finish with:

- [ ] At least three network placemarks
- [ ] At least one primary route path
- [ ] At least one alternate or diversity route path
- [ ] Distance estimate for each route
- [ ] Elevation profile reviewed for one path
- [ ] KML or KMZ file exported
- [ ] One limitation or uncertainty documented

## References

- Mapping Basics Within Google Earth Pro: https://cartong.pages.gitlab.cartong.org/learning-corner/assets/pdfs/toolbox9/6_2_1_Google_Earth/2022_Tutoriel_GoogleEarthPro_CartONG_EN.pdf
- Google Earth Tutorial - Part 1: https://docs.google.com/document/d/1yUw4J81IeCcV9zHlipny-IfmSvHA3LmFcC0ioiE54Ds/edit?tab=t.0#heading=h.q2a70u2e5j81
- KML Tutorial: https://developers.google.com/kml/documentation/kml_tut
