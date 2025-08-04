#!/bin/bash

# Test script for a few days to verify the batch process works

echo "Testing batch generation with 3 days..."

./wildfire "2025-08-01" -o "2025/wildfire-2025-08-01-z4-4x3.png"
./wildfire "2025-08-02" -o "2025/wildfire-2025-08-02-z4-4x3.png" 
./wildfire "2025-08-03" -o "2025/wildfire-2025-08-03-z4-4x3.png"

echo "Test batch completed! Check 2025/ directory."