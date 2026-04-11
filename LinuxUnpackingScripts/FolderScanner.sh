#!/bin/bash

# Script to recursively build directory structure from flat file list with prefixes

# Calculate absolute paths for both scripts at the very beginning
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOLDER_SCANNER_PATH="$SCRIPT_DIR/FolderScanner.sh"
PREFIX_REMOVER_PATH="$SCRIPT_DIR/PrefixRemover.sh"

# Get directory from parameter, or use current directory if not provided
if [ $# -ge 1 ]; then
    DIR="$1"
else
    DIR="."
fi

# Check if directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: Directory '$DIR' does not exist"
    exit 1
fi

# Change to the directory
cd "$DIR" || exit 1

echo "Processing directory: $(pwd)"

# Step 1: List all files sorted alphabetically and find first file with backslash
while true; do
    # Get list of files (not directories) sorted alphabetically
    first_file_with_backslash=""
    
    for file in *; do
        # Skip if it's a directory or doesn't exist
        if [ -d "$file" ] || [ ! -e "$file" ]; then
            continue
        fi
        
        # Check if this is an empty folder marker (file ending with just \)
        if [[ "$file" == *\\ ]]; then
            echo "Removing empty folder marker: '$file'"
            rm "$file"
            continue
        fi
        
        # Check if filename contains backslash
        if [[ "$file" == *\\* ]]; then
            first_file_with_backslash="$file"
            break
        fi
    done
    
    # Step 2: If no file with backslash found, we're done at this level
    if [ -z "$first_file_with_backslash" ]; then
        echo "No more files with backslash prefix in $(pwd)"
        break
    fi
    
    # Extract prefix (everything up to and including the first backslash)
    prefix="${first_file_with_backslash%%\\*}\\"
    
    echo "Found prefix: '$prefix'"
    
    # Step 3: Call PrefixRemover.sh with the extracted prefix
    "$PREFIX_REMOVER_PATH" "$prefix" "." || {
        echo "Error: PrefixRemover.sh failed"
        exit 1
    }
    
    # The new directory name is the prefix without trailing backslash
    new_dir="${prefix%\\}"
    
    echo ""
    
    # Step 4: Recursively call FolderScanner.sh into the newly created directory
    if [ -d "$new_dir" ]; then
        echo "Recursing into: $new_dir"
        echo "----------------------------------------"
        "$FOLDER_SCANNER_PATH" "$new_dir" || exit 1
        echo "----------------------------------------"
        echo "Returned from: $new_dir"
        echo ""
    fi
    
    # Step 5: Loop restarts - go back to step 1 to check for more prefixes
done

echo "Finished processing: $(pwd)"
echo ""
