# Universal Context Generator

A powerful and highly compatible shell script to generate a single-file context of any directory. It creates a summary file containing a smart directory tree and the contents of all relevant files, making it perfect for providing context to LLMs, archiving project states, or conducting code reviews.

This script is **environment-aware**: if run inside a Git repository, it will automatically use Git-aware features like `.gitignore` parsing for more precise filtering. If run in a standard directory, it gracefully falls back to universal `find`-based operations.

## Features

-   **Universal Operation**: Works in any directory, whether it's a Git repository or not.
-   **Intelligent Git Integration**: Automatically detects if it's in a Git repository to enable features like `.gitignore` support. Disables them gracefully otherwise.
-   **Smart Directory Tree**: Generates a visual tree of your project structure, respecting ignore rules.
-   **Ignored Directory Stats**: Displays the number of files and subdirectories hidden within an ignored folder (e.g., `<ignored 38 files, 22 directories>`).
-   **File Concatenation**: Appends the content of all included files into the same output file, wrapped in Markdown code blocks.
-   **Dual Filtering Logic**: Apply different include/exclude rules for the directory tree and the file contents separately.
-   **Force Include**: A powerful option to include specific files or directories, even if their parent is in an ignore list.
-   **High Compatibility**: Written in POSIX-compliant shell script to run on a wide range of systems, including macOS and various Linux distributions.
-   **Minimal Dependencies**: Relies only on standard Unix utilities (`find`, `wc`, `tr`, `sort`, `cat`). `git` is optional but recommended for full functionality in Git projects.

## Prerequisites

-   A Unix-like environment (Linux, macOS, WSL, etc.).
-   **`git` (Recommended)**: For the script to respect `.gitignore` files, `git` must be installed and the script must be run from within a Git repository. The script will still function without `git`, but with reduced capabilities.

## Installation

### Option 1: Using the provided Makefile (recommended)

The repository now includes a `Makefile` that installs a **symlink** to the script instead of copying it. This makes upgrades instant—just `git pull` and you're done.

Default prefix: `~/.local` (so the link goes to `~/.local/bin/myrepo`). Override with `PREFIX=/desired/path`.

```sh
make install                  # installs to ~/.local/bin/myrepo
make install PREFIX=/usr/local  # installs to /usr/local/bin/myrepo
```

Uninstall (removes only the symlink):

```sh
make uninstall
```

Notes:
- The install target refuses to overwrite a non-symlink file at the destination.
- Ensure `~/.local/bin` (or your chosen prefix bin dir) is on your PATH:
  ```sh
  export PATH="$HOME/.local/bin:$PATH"
  ```

### Option 2: Manual install (copy)

```sh
chmod +x myrepo
cp myrepo ~/.local/bin/
```

### Option 3: Ad‑hoc usage

Run it directly from the cloned directory:

```sh
./myrepo
```

## Usage

The script is designed to be intuitive. The most common options for filtering **file contents** have convenient shorthands. Options for filtering the **directory tree** are long-form and prefixed with `--tree-`.

```
Usage: myrepo [options]

Generates a single-file context snapshot of the current directory.
If run inside a Git repository, it will respect .gitignore files.

General Options:
  -o, --output <file>      Output file (default: ./repo.txt)
  -h, --help               Show this help and exit

Content Options (Part II - Primary):
  -E, --only-exclude <p>   Override default content exclude glob pattern.
  -e, --extra-exclude <p>  Add extra glob patterns to content exclude (pipe-separated).
  -i, --extra-include <p>  Force include files matching this glob pattern in content.
  -N, --no-gitignore       Don't use .gitignore for content filtering (has no effect outside a Git repo).

Tree Options (Part I - Long-only):
  --tree-only-exclude <p>   Override default tree exclude glob pattern.
  --tree-extra-exclude <p>  Add extra glob patterns to tree exclude.
  --tree-extra-include <p>  Force include files/dirs matching this glob pattern in the tree.
  --tree-no-gitignore       Don't use .gitignore for tree filtering.
```

### Filtering Logic

The script decides what to include or exclude based on the following order of precedence:

1.  **Force Include Rules (`-i`, `--tree-extra-include`)**: These have the highest priority. If a file or directory matches a force-include pattern, it will always be included.
2.  **Parent Directory Inclusion**: To honor a force-include rule, the script will automatically include all parent directories of the target file, even if those parents match an exclude rule.
3.  **Exclude Rules (`.gitignore`, `-e`, `-E`, etc.)**: If a file is not force-included, it will be checked against exclude rules. It is excluded if it matches:
    -   A pattern in `.gitignore` (if in a Git repo and enabled).
    -   A custom exclude pattern.
4.  **Default Inclusion**: If a file is not caught by any of the rules above, it is included by default.

## Examples

#### 1. Basic Usage (in a Git Repo)

Generate the context with all default settings, respecting `.gitignore`.
```sh
myrepo
```

#### 2. Basic Usage (in a standard directory)

Generate the context for a non-Git project. The script will note that `.gitignore` is not being used.
```sh
myrepo -o my_project_summary.md
```

#### 3. Exclude More File Types from Content

Generate the context, but exclude all log files and temporary files from the **content** section. This works in any directory.
```sh
myrepo -e "*.log|*.tmp"
```

#### 4. Hide a Directory from the Tree

Hide the `build/` directory from the **tree structure** display.
```sh
myrepo --tree-extra-exclude "build"
```

#### 5. Force-Include a Specific File

Even if the `dist/` directory is ignored in the tree, force the inclusion of `dist/assets/important.css` in both the tree and the content. The script will create the necessary parent directories in the tree to show the file's location.
```sh
myrepo --tree-extra-include "dist/assets/important.css" -i "dist/assets/important.css"
```

#### 6. Disable `.gitignore` for Content (in a Git Repo)

Include all files in the content section, even those listed in `.gitignore` (but still respecting the default/custom exclude patterns like `LICENSE` and `*.lock`). This flag has no effect outside of a Git repository.
```sh
myrepo -N
```

## License

This script is licensed under the Apache License 2.0.