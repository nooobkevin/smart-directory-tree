#!/bin/bash

# Function to print file content with formatting
print_file_content() {
    local file="$1"
    # Ensure the file exists before trying to cat it
    if [ -f "$file" ]; then
        echo
        echo "$file:"
        echo '```'
        cat -- "$file"
        echo '```'
    else
        # This shouldn't happen with the current logic, but good for safety
        echo "Error: Tried to print non-existent file '$file'" >&2
    fi
}

# Function to check if a file is ignored by Git
# Takes path relative to Git root
is_gitignored() {
    local file="$1"
    # Ensure check runs from repo root, handles paths correctly
    git check-ignore --quiet "$file"
    return $?
}

# --- Argument Parsing ---
TARGET_PATH="."
FILES_TO_PRINT=()

# Check if the first argument is a directory (our target path)
if [ $# -gt 0 ] && [ -d "$1" ]; then
    TARGET_PATH="$1"
    shift # Remove the directory from the arguments, rest are files/dirs to print
fi
# Remaining arguments are the specific files or directories to print
FILES_TO_PRINT=("$@")

# --- Validate Target Path ---
# Use realpath to get the absolute path for reliable comparison later
ABS_TARGET_PATH=$(realpath "$TARGET_PATH")
if [ ! -d "$ABS_TARGET_PATH" ]; then
    echo "Error: Target path '$TARGET_PATH' (resolved to '$ABS_TARGET_PATH') is not a valid directory." >&2
    exit 1
fi

# --- Git Repository Setup ---
# Determine Git root from the target path
GIT_ROOT=$(git -C "$ABS_TARGET_PATH" rev-parse --show-toplevel 2>/dev/null)
if [ -z "$GIT_ROOT" ]; then
    echo "Error: Target path '$ABS_TARGET_PATH' is not within a Git repository." >&2
    exit 1
fi

# Change to Git root directory for consistent relative paths
cd "$GIT_ROOT" || exit 1

# Calculate the path of the original TARGET_PATH relative to the GIT_ROOT
# This prefix is needed to correctly locate the arguments relative to the root
ARG_PREFIX=""
if [[ "$ABS_TARGET_PATH" != "$GIT_ROOT" ]]; then
    ARG_PREFIX=$(realpath --relative-to="$GIT_ROOT" "$ABS_TARGET_PATH")
fi

REPO_NAME=$(basename "$GIT_ROOT")

# --- Generate Tree Structure ---
echo "Repository Tree Structure ($REPO_NAME):"
# List tracked files from HEAD, pipe to tree
# Run tree from GIT_ROOT
git ls-tree -r --name-only HEAD | tree --fromfile --noreport -n | sed -e "1s|^\.|$REPO_NAME|"
echo # Add a newline after the tree

# --- Process Files/Directories to Print ---

# Use an associative array to keep track of files explicitly printed
# Key: Path relative to Git root, Value: 1 (or anything non-empty)
declare -A printed_explicit_files

echo "File Contents:"

# Pass 1: Print all explicitly requested *files*
for item_arg in "${FILES_TO_PRINT[@]}"; do
    # Construct path relative to GIT_ROOT
    item_path_relative_to_root="${ARG_PREFIX:+$ARG_PREFIX/}$item_arg"
    # Normalize path (remove potential ./)
    item_path_relative_to_root=$(realpath -m --relative-to="$GIT_ROOT" "$item_path_relative_to_root")

    if [ -f "$item_path_relative_to_root" ]; then
        # Check if already processed (e.g., duplicate args)
        if [[ ! -v printed_explicit_files["$item_path_relative_to_root"] ]]; then
             print_file_content "$item_path_relative_to_root"
             printed_explicit_files["$item_path_relative_to_root"]=1
        fi
    elif [ ! -d "$item_path_relative_to_root" ]; then
        # If it's not a file AND not a directory, it's an invalid argument here
        echo "Warning: Argument '$item_arg' (path '$item_path_relative_to_root') is not a valid file or directory relative to Git root. Skipping." >&2
    fi
done

# Pass 2: Process explicitly requested *directories*
for item_arg in "${FILES_TO_PRINT[@]}"; do
    # Construct path relative to GIT_ROOT
    item_path_relative_to_root="${ARG_PREFIX:+$ARG_PREFIX/}$item_arg"
    # Normalize path
    item_path_relative_to_root=$(realpath -m --relative-to="$GIT_ROOT" "$item_path_relative_to_root")

    if [ -d "$item_path_relative_to_root" ]; then
        # Find regular files directly within this directory
        find "$item_path_relative_to_root" -maxdepth 1 -type f -print0 | while IFS= read -r -d $'\0' file_in_dir; do
            # file_in_dir is already relative to GIT_ROOT because find started from there

            # Skip if it was already printed explicitly in Pass 1
            if [[ -v printed_explicit_files["$file_in_dir"] ]]; then
                continue
            fi

            # Skip if it's ignored by Git
            if is_gitignored "$file_in_dir"; then
                continue
            fi

            # If we reach here, it's a file in the requested dir,
            # it wasn't explicitly requested itself, and it's not ignored. Print it.
            print_file_content "$file_in_dir"
            # No need to mark as printed here, only explicit files matter for the check
        done
    fi
    # We already handled the case where it's not a dir or file in Pass 1
done

echo # Add a final newline for clean output