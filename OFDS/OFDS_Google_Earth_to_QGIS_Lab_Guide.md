# Lab Guide: Converting Fibre Maps to OFDS Using Google Earth and QGIS 3.44 LTR 

## Overview

This lab demonstrates how to:

1. Trace a fibre map from a PDF or image in Google Earth Pro.
2. Export the traced network as KML.
3. Convert KML to Open Fibre Data Standard (OFDS) format.
4. Install and configure OFDS Studio in QGIS 3.44 LTR.
5. Import and validate the resulting OFDS dataset.
6. Edit network geometry and metadata.

## Prerequisites

- Google Earth Pro
- QGIS 3.44 LTR 
- OFDS Studio plugin
- Fibre map PDF or image https://github.com/stevesong/OFDS-datasets
- KML2OFDS converter

Resources:

- Google Earth Pro
- QGIS 3.44 LTR
- https://github.com/stevesong/kml2ofds/
- https://kml2ofds.opentelecomdata.org

---

# Exercise 1: Trace a PDF or Image in Google Earth

## Step 1: Prepare the Map

1. Obtain a fibre network map.
2. If necessary, export the PDF page as PNG or JPG.
3. Save the image locally.

## Step 2: Locate the Target Area

1. Open Google Earth Pro.
2. Search for the country or region.
3. Allow Google Earth to centre the map.

## Step 3: Add an Image Overlay

1. Select **Add → Image Overlay**.
2. Browse to the saved image.
3. Load the image.

## Step 4: Align the Overlay

1. Adjust transparency.
2. Compare borders, roads, rivers and coastlines.
3. Stretch and move the image until it aligns correctly.

## Step 5: Create Project Folders

Create:

```
Network Name
├── Nodes
└── Spans
```

---

# Exercise 2: Create OFDS Nodes

## Step 6: Add Points of Presence

1. Zoom to a city or POP location.
2. Select **Add Placemark**.
3. Name the node.
4. Move the placemark into the **Nodes** folder.

Repeat for all visible POPs.

---

# Exercise 3: Create OFDS Spans

## Step 7: Add Fibre Routes

1. Select **Add Path**.
2. Change line colour and width.
3. Trace the fibre route.
4. Follow roads where appropriate.
5. Continue until the destination node.
6. Save the path into the **Spans** folder.

---

# Exercise 4: Export KML

## Step 8: Remove the Overlay

Do not export the image overlay.

Export only:

- Nodes
- Spans

## Step 9: Save as KML

1. Right-click the parent folder.
2. Select **Save Place As**.
3. Choose **KML**.
4. Do not use KMZ.

---

# Exercise 5: Convert KML to OFDS

## Option A: Web Converter

1. Open the KML2OFDS web tool.
2. Upload the KML file.
3. Enter metadata.
4. Click **Convert**.
5. Download the generated ZIP file.

## Option B: Local Converter

If the web site is unavailable:

1. Clone the GitHub repository.
2. Follow the repository instructions.
3. Generate OFDS JSON locally.

---

# Exercise 6: Install OFDS Studio

## Step 10: Install the Plugin

1. Open QGIS 3.44 LTR.
2. Select **Plugins → Manage and Install Plugins**.
3. Search for **OFDS Studio**.
4. Install the plugin.

---

# Exercise 7: Create an OFDS GeoPackage

## Important

Create the OFDS GeoPackage before adding background maps.

## Step 11: Create GeoPackage

1. Click **Create OFDS GeoPackage**.
2. Save the GeoPackage.

Example:

```
network.gpkg
```

---

# Exercise 8: Add a Basemap

## Step 12: Add XYZ Layer

1. Select **Layer → Add Layer → Add XYZ Layer**.
2. Add a Google or OpenStreetMap background layer.

## Step 13: Reorder Layers

Move the OFDS layers above the basemap.

---

# Exercise 9: Import OFDS Data

## Step 14: Extract the ZIP File

Extract the converter output.

Locate:

```
network.json
```

## Step 15: Import JSON

1. Click **Import OFDS JSON**.
2. Browse to the JSON file.
3. Import the dataset.

---

# Exercise 10: Visualise and Edit the Network

## Step 16: Enable Labels

Enable labels for:

- Nodes
- Spans

## Step 17: Edit Geometry

1. Toggle editing.
2. Use the Vertex Tool.
3. Adjust routes as required.

## Step 18: Edit Metadata

Update:

- Infrastructure owner
- Supporting infrastructure
- Operator information
- Route attributes

---

# Exercise 11: Validate the Dataset

## Step 19: Run Validation

1. Click **Validate**.
2. Confirm no schema errors are present.

---

# Exercise 12: Save and Publish

1. Save the GeoPackage.
2. Export updated OFDS data.
3. Commit data and source references to GitHub.
4. Preserve provenance information for all traced maps.

---

# Troubleshooting

| Issue | Resolution |
|---------|---------|
| OFDS layers not visible | Move OFDS layers above the basemap |
| XYZ layer unavailable | Verify internet access |
| JSON import empty | Ensure the OFDS JSON file was selected |
| Plugin errors | Create the GeoPackage before adding background layers |
| Geometry problems | Use the Vertex Tool to refine routes |


## References

- NZNOG OFDS presentation - https://youtu.be/zHCJov9WM-c?t=3422
- Introduction to Open Fibre Data Standard tools - https://www.youtube.com/watch?v=WVOz8_AR_X0
