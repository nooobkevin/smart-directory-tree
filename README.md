# DirTreePro

Enhanced directory tree generator with .gitignore awareness and file preview capabilities

## Features
- 📂 Auto-detects current directory as default root
- 🚫 Respects .gitignore rules and excludes .git/ 
- 📝 Optional file content preview
- 🌳 Clean ASCII tree formatting

## Prerequisite
```bash
pip install gitignore-parser
```

## Usage
```bash
# Basic usage (current directory)
dirtreepro

# Specific directory with file preview
dirtreepro path/to/dir file1.txt file2.js
```

## Examples
```bash
$ dirtreepro
project-root/
├── src/
│   └── index.js
└── README.md

$ dirtreepro .gitignore
.gitignore:
```
node_modules/
*.log
```