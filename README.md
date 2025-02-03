# smart-directory-tree
A Python script that generates directory trees and retrieve file content, while respecting `.gitignore` rules and excluding `.git/` directories.

## Features

- Generates folder structure with ASCII tree formatting
- Automatically ignores patterns from `.gitignore` files
- Excludes `.git/` directories by default
- Optional file content display for specified files

## Usage

```bash
python directory_tree.py <root_directory> [file1] [file2 ...]
```

**Example:**
```bash
python directory_tree.py my_project src/main.py
```

**Sample Output:**
```
my_project/
├── src/
│   ├── main.py
│   └── utils/
└── README.md

src/main.py:
print("Hello World")
```

## Requirements
- Python 3.6+
- `gitignore-parser` package (`pip install gitignore-parser`)
