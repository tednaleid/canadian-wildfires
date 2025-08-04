#!/bin/bash

# ABOUTME: Creates a 2x2 grid timelapse MP4 comparing wildfire seasons across multiple years
# ABOUTME: Usage: ./create_grid_timelapse.sh

set -e

echo "Creating grid timelapse from wildfire PNG files..."

# Create output directory for combined frames
mkdir -p combined_frames

# Get all unique month-day combinations that exist across any year directory
echo "Scanning for month-day combinations across all year directories..."
month_days=$(find 202{2,3,4,5} -name "wildfire-*.png" 2>/dev/null | \
        sed 's/.*wildfire-[0-9]\{4\}-\([0-9-]*\)-.*/\1/' | \
        sort -u)

if [ -z "$month_days" ]; then
    echo "Error: No wildfire PNG files found in 2022, 2023, 2024, or 2025 directories"
    exit 1
fi

date_count=$(echo "$month_days" | wc -l)
echo "Found $date_count unique month-day combinations to process"
echo ""

frame_num=0
for month_day in $month_days; do
    printf -v frame_file "combined_frames/frame_%04d.png" $frame_num
    echo "[$((frame_num + 1))/$date_count] Processing $month_day..."
    
    # Find files for this month-day in each year directory
    files=()
    labels=()
    
    for year in 2022 2023 2024 2025; do
        file=$(find $year -name "wildfire-$year-$month_day-*.png" 2>/dev/null | head -1)
        if [ -n "$file" ] && [ -f "$file" ]; then
            files+=("$file")
            labels+=("$year")
            echo "  Found: $file"
        else
            # Create blank placeholder with year label (8:5 aspect ratio)
            convert -size 2048x1280 xc:black \
                    -fill white -pointsize 64 -gravity center \
                    -annotate +0+0 "$year\n(no data)" \
                    "blank_$year.png"
            files+=("blank_$year.png")
            labels+=("$year")
            echo "  Missing: $year (using blank)"
        fi
    done
    
    # Create 2x2 montage with labels (preserve 8:5 aspect ratio)
    # Top row: 2022 (NW), 2023 (NE)  
    # Bottom row: 2024 (SW), 2025 (SE)
    # Each quadrant: 1024x640 to maintain 8:5 ratio
    montage "${files[0]}" "${files[1]}" "${files[2]}" "${files[3]}" \
            -geometry 1024x640+1+1 -tile 2x2 \
            -background black -bordercolor white -border 1 \
            "$frame_file"
    
    # Date overlay removed - dates are already on individual images
    
    # Clean up blank files
    rm -f blank_*.png
    ((frame_num++))
done

echo ""
echo "Created $frame_num combined frames"
echo "Creating MP4 video..."

# Create MP4 from frames
output_file="wildfire_comparison_$(date +%Y%m%d).mp4"
ffmpeg -y -framerate 10 -i "combined_frames/frame_%04d.png" \
       -c:v libx264 -pix_fmt yuv420p -crf 23 \
       "$output_file"

echo ""
echo "🎉 Successfully created: $output_file"
echo "Grid layout:"
echo "  ┌─────────┬─────────┐"
echo "  │  2022   │  2023   │"
echo "  ├─────────┼─────────┤"
echo "  │  2024   │  2025   │"
echo "  └─────────┴─────────┘"
echo ""
echo "Video stats:"
echo "  Frames: $frame_num"
echo "  Duration: ~$((frame_num / 10)) seconds at 10fps"
echo "  Resolution: 2048x1280 (8:5 aspect ratio preserved)"
echo ""

# Clean up temporary frames
read -p "Delete temporary frames directory? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf combined_frames
    echo "Temporary frames deleted."
else
    echo "Temporary frames kept in: combined_frames/"
fi