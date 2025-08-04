#!/bin/bash

# ABOUTME: Flexible script to generate wildfire maps for a range of consecutive days
# ABOUTME: Usage: ./generate_maps.sh START_DATE NUM_DAYS [OUTPUT_DIR]

set -e  # Exit on any error

# Function to show usage
usage() {
    echo "Usage: $0 START_DATE NUM_DAYS [OUTPUT_DIR]"
    echo ""
    echo "Arguments:"
    echo "  START_DATE   Starting date in YYYY-MM-DD format (e.g., 2025-04-01)"
    echo "  NUM_DAYS     Number of consecutive days to generate maps for"
    echo "  OUTPUT_DIR   Optional output directory (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  $0 2025-04-01 126                    # April 1 - Aug 4 (126 days)"
    echo "  $0 2025-08-01 7                     # One week starting Aug 1"
    echo "  $0 2025-04-01 126 2025              # Save to 2025/ directory"
    echo "  $0 2025-07-01 31 july_maps          # July 2025 in july_maps/ directory"
    exit 1
}

# Check arguments
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    usage
fi

START_DATE="$1"
NUM_DAYS="$2"
OUTPUT_DIR="${3:-.}"  # Default to current directory if not specified

# Validate start date format (works on both macOS and Linux)
if [[ ! "$START_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: Invalid date format '$START_DATE'. Use YYYY-MM-DD format."
    exit 1
fi

# Validate number of days
if ! [[ "$NUM_DAYS" =~ ^[0-9]+$ ]] || [ "$NUM_DAYS" -lt 1 ]; then
    echo "Error: NUM_DAYS must be a positive integer, got '$NUM_DAYS'"
    exit 1
fi

# Create output directory if it doesn't exist
if [ "$OUTPUT_DIR" != "." ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Calculate end date for display (macOS compatible)
END_DATE=$(date -j -v+$((NUM_DAYS - 1))d -f "%Y-%m-%d" "$START_DATE" "+%Y-%m-%d")

echo "Generating wildfire maps..."
echo "Start date: $START_DATE"
echo "End date: $END_DATE"
echo "Number of days: $NUM_DAYS"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Generate maps for each day
for (( i=0; i<NUM_DAYS; i++ )); do
    # Calculate current date (macOS compatible)
    current_date=$(date -j -v+${i}d -f "%Y-%m-%d" "$START_DATE" "+%Y-%m-%d")
    
    # Progress indicator
    progress=$((i + 1))
    echo "[$progress/$NUM_DAYS] Generating map for $current_date..."
    
    # Determine output file path
    if [ "$OUTPUT_DIR" = "." ]; then
        output_file="wildfire-${current_date}-z4-4x3.png"
    else
        output_file="$OUTPUT_DIR/wildfire-${current_date}-z4-4x3.png"
    fi
    
    # Generate the map
    ./wildfire "$current_date" -o "$output_file"
    
    echo "  ✓ Saved: $output_file"
    echo ""
done

echo "🎉 All $NUM_DAYS wildfire maps generated successfully!"
echo "Date range: $START_DATE to $END_DATE"
echo "Location: $OUTPUT_DIR"
echo ""
echo "Useful commands:"
echo "  ls -la $OUTPUT_DIR/wildfire-*.png | wc -l    # Count generated files"
echo "  du -sh $OUTPUT_DIR                           # Check total size"