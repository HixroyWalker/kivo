#!/bin/bash
# KiVo Image Optimizer
# Converts marketplace photos to WebP to save 90% storage space.

set -e  # Exit on error

# Configuration
ASSETS_DIR="./assets"
QUALITY=80
VERBOSE=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Usage message
usage() {
    echo "Usage: $0 [-d DIRECTORY] [-q QUALITY] [-v]"
    echo "  -d DIRECTORY  Assets directory (default: ./assets)"
    echo "  -q QUALITY    WebP quality 1-100 (default: 80)"
    echo "  -v            Verbose output"
    exit 1
}

# Parse arguments
while getopts "d:q:vh" opt; do
    case $opt in
        d) ASSETS_DIR="$OPTARG" ;;
        q) QUALITY="$OPTARG" ;;
        v) VERBOSE=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Validate quality parameter
if ! [[ "$QUALITY" =~ ^[0-9]+$ ]] || [ "$QUALITY" -lt 1 ] || [ "$QUALITY" -gt 100 ]; then
    echo -e "${RED}Error: Quality must be between 1 and 100${NC}"
    exit 1
fi

# Check if cwebp is installed
if ! command -v cwebp &> /dev/null; then
    echo -e "${YELLOW}Warning: cwebp not found. Installing libwebp...${NC}"
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y webp
    elif command -v brew &> /dev/null; then
        brew install webp
    else
        echo -e "${RED}Error: Please install libwebp manually (cwebp command required)${NC}"
        exit 1
    fi
fi

# Check if directory exists
if [ ! -d "$ASSETS_DIR" ]; then
    echo -e "${RED}Error: Assets directory not found: $ASSETS_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}KiVo Image Optimizer${NC}"
echo "Optimizing assets for Santa Cruz Pilot..."
echo "Directory: $ASSETS_DIR"
echo "Quality: $QUALITY"
echo ""

converted_count=0
total_original_size=0
total_optimized_size=0
error_count=0

# Process JPG files
while IFS= read -r -d '' file; do
    if [ -z "$file" ]; then
        continue
    fi
    
    filename=$(basename "$file")
    dirname=$(dirname "$file")
    basename_no_ext="${filename%.*}"
    webp_file="${dirname}/${basename_no_ext}.webp"
    
    # Get original file size
    original_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    
    if [ -n "$VERBOSE" ] || [ "$VERBOSE" = true ]; then
        echo "Processing: $filename"
    fi
    
    # Convert to WebP
    if cwebp -q "$QUALITY" "$file" -o "$webp_file" 2>/dev/null; then
        # Get optimized file size
        optimized_size=$(stat -f%z "$webp_file" 2>/dev/null || stat -c%s "$webp_file" 2>/dev/null)
        savings=$((original_size - optimized_size))
        savings_percent=$((savings * 100 / original_size))
        
        total_original_size=$((total_original_size + original_size))
        total_optimized_size=$((total_optimized_size + optimized_size))
        converted_count=$((converted_count + 1))
        
        if [ "$VERBOSE" = true ]; then
            echo -e "  ${GREEN}✓ Converted${NC} - Original: ${original_size}B, Optimized: ${optimized_size}B, Saved: ${savings_percent}%"
        fi
    else
        echo -e "  ${RED}✗ Failed${NC} to convert: $filename"
        error_count=$((error_count + 1))
    fi
done < <(find "$ASSETS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0)

# Calculate totals
echo ""
echo -e "${GREEN}=== Optimization Complete ===${NC}"
echo "Files converted: $converted_count"
echo "Conversion errors: $error_count"

if [ $total_original_size -gt 0 ]; then
    total_savings=$((total_original_size - total_optimized_size))
    total_savings_percent=$((total_savings * 100 / total_original_size))
    echo "Original total size: ${total_original_size}B"
    echo "Optimized total size: ${total_optimized_size}B"
    echo -e "${GREEN}Total saved: ${total_savings}B (${total_savings_percent}%)${NC}"
fi

if [ $error_count -gt 0 ]; then
    exit 1
fi

exit 0
