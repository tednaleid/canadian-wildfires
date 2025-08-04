# ABOUTME: Documents technical analysis of Canadian Wildfire Information System (CWFIS) API endpoints and layer configuration
# ABOUTME: Contains critical information for programmatically accessing fire perimeter data and base map tiles

# Canadian Wildfire Information System (CWFIS) API Analysis

## Overview
Analysis of the CWFIS interactive map system to understand how to programmatically access wildfire data and base map tiles for creating automated wildfire maps.

## Key Findings - Layer Configuration

### Critical Layer Selection Issue
The CWFIS website has **multiple overlay layers** that can be toggled on/off. By default, the **Fire Weather Index** layer is enabled, but this shows fire danger ratings (colored zones), NOT actual fire perimeters.

**To get actual fire perimeters, you must:**
1. **Disable** the "Fire Weather Index" layer (checkbox ID: `fwi_toggle`)
2. **Enable** the "Fire Perimeter Estimate" layer (checkbox ID: `poly_toggle`)

### Available Layers
| Layer Name | Checkbox ID | Description | Default State |
|------------|-------------|-------------|---------------|
| Fire Weather Index | `fwi_toggle` | Fire danger ratings (colored zones) | ✅ Enabled |
| Fire Danger | `fdr_toggle` | Provincial fire danger classifications | ❌ Disabled |
| **Fire Perimeter Estimate** | `poly_toggle` | **Actual wildfire perimeters (polygons)** | ❌ Disabled |
| Fire M3 Hotspots | `firem3_toggle` | 24-hour hotspot data | ❌ Disabled |
| Season-to-date Hotspots | `std_hotspots_toggle` | Cumulative hotspots | ❌ Disabled |
| Active Fires | `active_fires_toggle` | Fire status by control stage | ❌ Disabled |
| Forecast weather stations | `fcst_wxn_toggle` | Weather forecast points | ❌ Disabled |
| Reporting weather stations | `wxn_toggle` | Weather monitoring stations | ❌ Disabled |
| Fire History | `fire_history_toggle` | Historical fire perimeters | ❌ Disabled |

## Technical API Details

### Base Map Tiles (WMTS)
```
https://maps-cartes.services.geo.ca/server2_serveur2/rest/services/BaseMaps/CBMT3978/MapServer/WMTS/tile/1.0.0/BaseMaps_CBMT3978/default/default028mm/{z}/{x}/{y}.jpg
```
- **Coordinate System**: EPSG:3978 (Canada Atlas Lambert)
- **Tile Size**: 256x256 pixels
- **Format**: JPEG
- **Zoom levels**: Multiple (observed levels 5-6 for 200km resolution)

### Fire Perimeter Data (WMS)
```
https://cwfis.cfs.nrcan.gc.ca/geoserver/public/wms?
SERVICE=WMS&
VERSION=1.3.0&
REQUEST=GetMap&
FORMAT=image/png&
TRANSPARENT=true&
LAYERS=public:m3_polygons&
CQL_FILTER=mindate <= '2025-08-04 12:00:00' and maxdate >= '2025-08-04 12:00:00'&
WIDTH=256&
HEIGHT=256&
CRS=EPSG:3978&
STYLES=&
BBOX={minx},{miny},{maxx},{maxy}
```

**Key Parameters:**
- **Layer**: `public:m3_polygons` (fire perimeter polygons)
- **Date Filter**: CQL filter with date range matching the target date
- **Format**: PNG with transparency for overlay
- **Coordinate System**: EPSG:3978 (same as base map)

### Fire Weather Index Data (WMS) - For Reference
```
https://cwfis.cfs.nrcan.gc.ca/geoserver/public/wms?
LAYERS=public:fwi20250804sf&
STYLES=cffdrs_fwi_opaque
```
- **Layer Pattern**: `public:fwi{YYYYMMDD}sf` (e.g., `fwi20250804sf`)
- **Style**: `cffdrs_fwi_opaque`

## Date Handling
- **Input Format**: ISO8601 date (e.g., `2025-08-04`)
- **URL Parameters**: `month=8&day=4&year=2025`
- **CQL Filter Format**: `'YYYY-MM-DD HH:MM:SS'` (use `12:00:00` for time)
- **Fire Weather Layer**: Date is embedded in layer name `fwi{YYYYMMDD}sf`

## Map Configuration
- **Default Zoom**: 3 (200km resolution)
- **Default Center**: `-489719.35496475064,659612.9289316565` (EPSG:3978 coordinates)
- **Projection**: Canada Atlas Lambert (EPSG:3978)

## Programming Implications

### For Python Implementation:
1. **Date Processing**: Convert ISO8601 → CQL filter format
2. **Layer Selection**: Must programmatically request fire perimeters, not fire weather
3. **Coordinate System**: All requests must use EPSG:3978
4. **Tile Stitching**: Base map and fire overlay tiles need to be composited
5. **Transparency**: Fire perimeter layer uses PNG with transparency

### Critical Success Factors:
- ✅ Use `public:m3_polygons` layer for actual fire perimeters
- ✅ Apply correct date filter in CQL format
- ✅ Ensure EPSG:3978 coordinate system consistency
- ✅ Handle PNG transparency for fire overlay
- ❌ Don't use Fire Weather Index layer if you want perimeters

## Sample Working Request
```bash
# Base map tile (example)
https://maps-cartes.services.geo.ca/server2_serveur2/rest/services/BaseMaps/CBMT3978/MapServer/WMTS/tile/1.0.0/BaseMaps_CBMT3978/default/default028mm/5/56/50.jpg

# Fire perimeter overlay (example)
https://cwfis.cfs.nrcan.gc.ca/geoserver/public/wms?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS=public%3Am3_polygons&cql_filter=mindate%20%3C%3D%20%272025-08-04%2012%3A00%3A00%27%20and%20maxdate%20%3E%3D%20%272025-08-04%2012%3A00%3A00%27&WIDTH=256&HEIGHT=256&CRS=EPSG%3A3978&STYLES=&BBOX=-1162500%2C661250%2C-368750%2C1455000
```

## Testing Notes
- Tested on 2025-08-04 data
- Fire perimeters visible primarily in western Canada (BC, AB, SK, MB) and northern Ontario
- Base map loads reliably from backup server (maps-cartes.services.geo.ca)
- Fire data requires proper date filtering to return results