#!/bin/bash

# Script to remove a prefix from filenames

# Check if prefix argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <prefix> [directory]"
    echo "Example: $0 'Unpath\\' /path/to/your/files"
    echo "Example: $0 'Unpath\\' (uses current directory)"
    exit 1
fi

# Get prefix from first parameter
PREFIX="$1"

# Get directory from second parameter, or use current directory if not provided
if [ $# -ge 2 ]; then
    DIR="$2"
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

echo "Working in directory: $(pwd)"
echo "Removing prefix: '$PREFIX'"
echo ""

# Create directory name from prefix (remove trailing backslash if present)
DIRNAME="${PREFIX%\\}"

# Create the directory if it doesn't exist
if [ ! -d "$DIRNAME" ]; then
    mkdir "$DIRNAME"
    echo "Created directory: '$DIRNAME'"
else
    echo "Directory '$DIRNAME' already exists"
fi
echo ""

# Counter for renamed files
count=0

# Process files with the specified prefix
for file in "$PREFIX"*; do
    # Check if any matching files exist
    if [ ! -e "$file" ]; then
        echo "No files found with '$PREFIX' prefix"
        exit 0
    fi
    
    # Remove the prefix
    newname="${file#$PREFIX}"
    
    # Construct the target path (inside the new directory)
    target="$DIRNAME/$newname"
    
    # Check if target filename already exists
    if [ -e "$target" ]; then
        echo "Warning: '$target' already exists, skipping '$file'"
        continue
    fi
    
    # Move and rename the file
    mv "$file" "$target"
    echo "Moved: '$file' → '$target'"
    ((count++))
done

echo ""
echo "Done! Moved $count file(s) into '$DIRNAME/'"
