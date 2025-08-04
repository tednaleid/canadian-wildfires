#!/bin/bash

# ABOUTME: Flexible script to generate wildfire maps for a date range
# ABOUTME: Usage: ./generate_maps.sh START_DATE END_DATE [OUTPUT_DIR]

set -e  # Exit on any error

# Function to show usage
usage() {
    echo "Usage: $0 START_DATE END_DATE [OUTPUT_DIR]"
    echo ""
    echo "Arguments:"
    echo "  START_DATE   Starting date in YYYY-MM-DD format (e.g., 2025-04-01)"
    echo "  END_DATE     Ending date in YYYY-MM-DD format (e.g., 2025-08-04)"
    echo "  OUTPUT_DIR   Optional output directory (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  $0 2025-04-01 2025-08-04                # April 1 through Aug 4"
    echo "  $0 2025-08-01 2025-08-07                # One week in August"
    echo "  $0 2025-04-01 2025-08-04 2025           # Save to 2025/ directory"
    echo "  $0 2025-07-01 2025-07-31 july_maps     # July 2025 in july_maps/ directory"
    exit 1
}

# Check arguments
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    usage
fi

START_DATE="$1"
END_DATE="$2"
OUTPUT_DIR="${3:-.}"  # Default to current directory if not specified

# Validate start date format
if [[ ! "$START_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: Invalid start date format '$START_DATE'. Use YYYY-MM-DD format."
    exit 1
fi

# Validate end date format
if [[ ! "$END_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: Invalid end date format '$END_DATE'. Use YYYY-MM-DD format."
    exit 1
fi

# Convert dates to seconds since epoch for comparison
start_epoch=$(date -j -f "%Y-%m-%d" "$START_DATE" "+%s")
end_epoch=$(date -j -f "%Y-%m-%d" "$END_DATE" "+%s")

# Validate that end date is after start date
if [ "$end_epoch" -lt "$start_epoch" ]; then
    echo "Error: End date '$END_DATE' must be after start date '$START_DATE'."
    exit 1
fi

# Calculate number of days between start and end dates (inclusive)
NUM_DAYS=$(( (end_epoch - start_epoch) / 86400 + 1 ))

# Create output directory if it doesn't exist
if [ "$OUTPUT_DIR" != "." ]; then
    mkdir -p "$OUTPUT_DIR"
fi

echo "Generating wildfire maps..."
echo "Start date: $START_DATE"
echo "End date: $END_DATE"
echo "Number of days: $NUM_DAYS"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Generate maps for each day
for (( i=0; i<NUM_DAYS; i++ )); do
    # Calculate current date by adding i days to start date
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