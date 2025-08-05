# Project

Canadian wildfires have been significant in 2025.

The Canadian government has a website that with an interactive map, implemented with <canvas> tags, that shows active wildfires.

This is an example URL that shows the active wildfires for August 4th, 2025: https://cwfis.cfs.nrcan.gc.ca/interactive-map?zoom=3&center=-489719.35496475064%2C659612.9289316565&month=8&day=4&year=2025#iMap

The goal for this project is to scrape this website to create an image out of the map tiles and wildfire information for a given day.

The playwright MCP is installed and can be used to interact with the website if necessary.

Let's start at the zoom level given in the url above, which is at the 200km resolution.  Eventually, we might want the zoom level to be interactive in the map we download.

The goal is to create a command line utility in `python`, utilizing a `uv` shebang with dependencies so that it is self contained, that can be given an ISO8601 date (ex: 2025-08-04) and have it download an image of the map for that day, with the wildfires that were active during that day. ex:

```
wildfire 2025-08-04
```
