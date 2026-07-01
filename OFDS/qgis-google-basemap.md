# Adding a Google Road Map Background to QGIS Using XYZ Tiles

This guide explains how to add a Google Road Map as a background layer in QGIS using the built-in XYZ Tiles functionality.

## Prerequisites

- QGIS 3.x installed
- Internet connection
- Browser Panel enabled in QGIS

## Step 1: Enable the Browser Panel

If the Browser Panel is not visible:

1. Open QGIS.
2. Select **View → Panels → Browser Panel**.
3. Confirm that the Browser Panel appears on the left side of the QGIS window.

## Step 2: Create a New XYZ Tile Connection

1. In the Browser Panel, locate **XYZ Tiles**.
2. Right-click **XYZ Tiles**.
3. Select **New Connection**.

Enter the following values:

| Setting | Value |
|----------|----------|
| Name | Google Road Map |
| URL | `https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}` |

4. Click **OK**.

## Step 3: Add the Layer to the Map

1. Expand **XYZ Tiles** in the Browser Panel.
2. Locate **Google Road Map**.
3. Double-click the layer, or drag it onto the map canvas.

The Google Road Map background should now be visible.

## Other Useful Google Map Layers

| Layer                       | URL                                                  |
| --------------------------- | ---------------------------------------------------- |
| Road Map                    | `https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}` |
| Satellite                   | `https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}` |
| Hybrid (Satellite + Labels) | `https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}` |
| Terrain                     | `https://mt1.google.com/vt/lyrs=t&x={x}&y={y}&z={z}` |


## Alternative: OpenStreetMap

For many GIS projects, OpenStreetMap provides an excellent background layer with clear usage terms.

| Setting | Value |
|----------|----------|
| Name | OpenStreetMap |
| URL | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` |

## Troubleshooting

### Layer Does Not Load

Check:

- Internet connectivity.
- Firewall or proxy settings.
- The XYZ URL has been entered exactly as shown.

### Map Appears Blank

Verify that:

- The project CRS is set to **EPSG:3857 (Web Mercator)**.
- You have zoomed to an area where tiles are available.

### Browser Panel Missing

Enable it from:

**View → Panels → Browser Panel**

## Licensing Considerations

Google does not officially provide these tile URLs as a supported GIS service. While many QGIS users access Google map layers via XYZ Tiles, Google's terms of service may restrict usage outside the official Google Maps Platform APIs. Review Google's licensing requirements before using these layers in publications, client work, or commercial projects.

## References

- https://youtu.be/WVOz8_AR_X0?t=1022
- [Mapscaping: Google Satellite Imagery and Google Maps in QGIS](https://mapscaping.com/google-satellite-imagery-and-google-maps-in-qgis/)
- [Hatari Labs: Adding Google Maps as XYZ Tiles in QGIS](https://hatarilabs.com/ih-en/how-to-add-a-google-map-in-qgis-3-tutorial)
