#!/bin/bash

print_file_content() {
local file="$1"
echo
echo "$file:"
echo '```'
cat -- "$file"
echo '```'
}

# Parse arguments
TARGET_PATH="."
FILES_TO_PRINT=()

if [ $# -gt 0 ] && [ -d "$1" ]; then
TARGET_PATH="$1"
shift
fi

FILES_TO_PRINT=("$@")

# Check if TARGET_PATH is valid
if [ ! -d "$TARGET_PATH" ]; then
echo "Error: Target path $TARGET_PATH is not a directory" >&2
exit 1
fi

# Determine Git root
cd "$TARGET_PATH" || exit 1
if ! GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
echo "Error: Not a Git repository: $TARGET_PATH" >&2
exit
fi
cd "$GIT_ROOT" || exit 1

# Compute relative path from GIT_ROOT to TARGET_PATH
REL_PATH=$(realpath --relative-to="$GIT_ROOT" "$TARGET_PATH")

REPO_NAME=$(basename "$GIT_ROOT")

# Generate the tree structure
git ls-tree -r --name-only HEAD | tree --fromfile --noreport -n | sed -e "1s|^\.|$REPO_NAME/|"

# Process files to print
for file_arg in "${FILES_TO_PRINT[@]}"; do
full_path="$REL_PATH/$file_arg"
if [ -f "$full_path" ]; then
    if ! git check-ignore --quiet "$full_path"; then
        print_file_content "$full_path"
    fi
elif [ -d "$full_path" ]; then
    find "$full_path" -maxdepth 1 -type f -print0 | while IFS= read -r -d $'\0' file; do
        if ! git check-ignore --quiet "$file"; then
            print_file_content "$file"
        fi
    done
else
echo "Error: '$full_path' does not exist." >&2
fi
done
