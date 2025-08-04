# Canadian Wildfire Map Scraper - Implementation Plan

## Overview
Create a Python command-line utility that captures wildfire map images from the Canadian Wildfire Information System (CWFIS) for a given date.

## Technical Approach
- **Language**: Python with uv shebang for self-contained execution
- **Investigation Tool**: Playwright MCP (for exploring the website during development)
- **Implementation Strategy**: 
  - Preferably: Direct API/tile server access if discoverable
  - Fallback: Web scraping with requests/selenium if needed
- **Input**: ISO8601 date format (e.g., 2025-08-04)
- **Output**: PNG/JPEG image of the map with active wildfires

## Implementation Tasks

### Phase 1: Analysis & Investigation (Using Playwright MCP)
1. **Explore the Canadian wildfire website** 
   - Use playwright MCP to navigate to the site
   - Inspect network requests to find tile server URLs
   - Document the URL parameter structure

2. **Investigate map tile loading**
   - Identify tile server endpoints (WMS, XYZ tiles, etc.)
   - Understand the tile coordinate system
   - Find the base map source

3. **Identify wildfire data sources**
   - Look for API endpoints that provide wildfire locations
   - Check for GeoJSON, KML, or other data formats
   - Understand how wildfire data is fetched for specific dates

### Phase 2: Core Implementation
4. **Create Python script skeleton**
   - Set up uv shebang with required dependencies
   - Create main function structure
   - Add basic command-line interface

5. **Implement date handling**
   - Parse ISO8601 date input
   - Validate date ranges
   - Convert to format required by the website URL

6. **Implement map generation**
   - If tile endpoints found: Fetch tiles directly and stitch them together
   - If API found: Overlay wildfire data on base map tiles
   - Fallback: Use selenium/requests to capture rendered map

7. **Handle wildfire data overlay**
   - Parse wildfire location data for the given date
   - Render fire symbols/markers on the map
   - Ensure proper positioning and scaling

8. **Generate final image**
   - Combine base map and wildfire overlays
   - Save at appropriate resolution (200km zoom level)
   - Include date in filename

### Phase 3: Polish & Testing
9. **Error handling**
   - Handle invalid date inputs gracefully
   - Manage network timeouts and failures
   - Provide clear error messages

10. **Testing**
    - Test with various dates (past, present)
    - Verify map captures are consistent
    - Ensure script works on different systems

11. **Command-line improvements**
    - Add --help documentation
    - Consider additional options (output filename, format)
    - Add version information

12. **Performance optimization**
    - Minimize browser startup time
    - Cache resources if possible
    - Add progress indicators for user feedback

## Key Considerations

### Technical Challenges
- Canvas-based rendering may require special handling
- Map tiles might load asynchronously
- Need to ensure all wildfire data is loaded before capture

### URL Parameters
Base URL: `https://cwfis.cfs.nrcan.gc.ca/interactive-map`
- `zoom=3` (200km resolution)
- `center=-489719.35496475064%2C659612.9289316565`
- `month=8&day=4&year=2025`

### Dependencies Expected
- requests (for fetching tiles/data)
- Pillow (for image processing and stitching)
- click or argparse (for CLI)
- datetime (for date handling)
- selenium (only if direct API access not possible)

## Questions to Consider
1. Should we support different zoom levels as a parameter?
2. Do we want to crop the image to specific boundaries?
3. Should we add legend/date information to the captured image?
4. Is there a need to capture multiple dates in batch?
5. Should we detect if no wildfires are present on a given date?