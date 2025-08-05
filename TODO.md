- [X] change `wildfire` so that it has an option to layer the polygons from multiple years in a single image. Current behavior is:

        ./wildfire 2025-08-01 2025-08-04 -o 2025 -z 6 -w 9 -h 4

 will work normally, because the start date and the end date are both in 2025, so this would create images for august 1st through august 4th with the fire polygons for each day in 2025 laid on top and with a date in the corner of "2025-08-01" in red.

The way I'd like it to work is if there is an end date, and if that end date is in a year after the end date of the year in the start date, we will create daily images with polygons for all years between those years combined.  And the date we overlay in the upper right will be a range of dates.  So if the command were:

    ./wildfire 2024-08-01 2025-08-04 -o 2025 -z 6 -w 9 -h 4

This has a start date in 2024 and an end date in 2025.  With current behavior, it'd create ~369 images for all the days between those two days.  Instead, I want it to create the same 4 images for August 1st through August 4th, but it should overlay both the 2024 and 2025 polygons on the same map tiles.  So the image for August 1st would have the 2024-08-01 AND the 2025-08-01 polygons on it.  The August 2nd image would have the 2024 and 2025 polygons on it.  Additionally, the date that we print in the upper right of the image will change to: 2024-2025 08-01, and the filename will change to include 2024-2025-08-01.

  