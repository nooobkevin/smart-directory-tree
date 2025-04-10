# DirTreePro (dirtreepro.sh)

Generates a directory tree structure for a Git repository and optionally previews the content of specified files or files within specified directories. It respects `.gitignore` rules for directory contents but allows overriding ignores for explicitly requested files.

## Features

*   📂 Displays a tree of files tracked by Git within a specified directory (defaults to current).
*   🎯 Operates within the context of the Git repository containing the target directory. Fails gracefully if not in a Git repo.
*   📄 Optionally previews the content of files specified as arguments.
*   🔍 Previews files within specified directories, automatically skipping files ignored by `.gitignore`.
*   ❗ **Overrides `.gitignore`**: Files explicitly listed as arguments will be previewed *even if* they are ignored.
*   🌳 Uses `tree` for clean ASCII tree formatting.
*   ⚙️ Relies on standard command-line utilities.

## Prerequisites

Requires a Bash-compatible shell and the following command-line tools to be installed and available in your system's PATH:

*   `git`
*   `tree`
*   `find`
*   `cat`
*   `sed`
*   `realpath` (usually part of `coreutils`)

These tools are commonly available on Linux and macOS. You might need to install `tree` or `coreutils` using your package manager if they are missing (e.g., `sudo apt update && sudo apt install tree coreutils` on Debian/Ubuntu, `brew install tree coreutils` on macOS).

## Installation

1.  Save the script code to a file, for example, `dirtreepro.sh`.
2.  Make it executable:
    ```bash
    chmod +x dirtreepro.sh
    ```
3.  (Optional) To run it from anywhere, either move it to a directory in your PATH:
    ```bash
    sudo mv dirtreepro.sh /usr/local/bin/dirtreepro
    ```
    or create a symbolic link in a directory within your PATH:
    ```bash
    sudo ln -s "$(pwd)/dirtreepro.sh" /usr/local/bin/dirtreepro
    ```
    (If you do this, you can invoke the script as `dirtreepro` instead of `./dirtreepro.sh`).

## Usage

```bash
./dirtreepro.sh [target_directory] [file_or_dir_to_print...]
```

*   **`target_directory`**: (Optional) The directory to analyze. Defaults to the current directory (`.`). Must be located inside a Git repository.
*   **`file_or_dir_to_print...`**: (Optional) Specific files or directories whose contents should be displayed. Paths should be relative to `target_directory`.

## Behavior Details

1.  The script first changes to the root directory of the Git repository containing the `target_directory`.
2.  It displays the tree structure of all files tracked by Git (`git ls-tree HEAD`) within the repository, starting from the root, using the `tree` command.
3.  It then processes the `file_or_dir_to_print` arguments provided:
    *   If an argument corresponds to a **file** (relative to the Git root), its content is printed. This happens **regardless** of whether the file is listed in `.gitignore`.
    *   If an argument corresponds to a **directory** (relative to the Git root), the script looks for files directly inside that directory.
    *   A file found inside such a directory is printed **only if**:
        *   It was *not* already printed because it was explicitly listed as a file argument itself.
        *   It is *not* ignored by the repository's `.gitignore` rules (checked using `git check-ignore`).

## Examples

*(Assuming the script is named `dirtreepro.sh` and is in the current directory or PATH)*

```bash
# Show tree for the Git repo containing the current directory
./dirtreepro.sh
```

```bash
# Show tree for the repo, and preview the content of '.gitignore' and 'src/main.js'
# (Paths are relative to the current directory, assuming '.' is the target)
./dirtreepro.sh .gitignore src/main.js
```

```bash
# Show tree for the repo containing the 'project-a' subdirectory
# Preview the file 'project-a/config.yaml'
# Preview non-ignored files within the 'project-a/data' directory
./dirtreepro.sh project-a project-a/config.yaml project-a/data
```

**Example Output Structure:**

```
Repository Tree Structure (your-repo-name):
your-repo-name
├── .gitignore
├── data/
│   ├── input.csv
│   └── processed.log  # (Ignored, won't be printed by default if 'data' is specified)
├── project-a/
│   ├── config.yaml
│   └── data/
│       └── results.txt # (Not ignored)
├── dirtreepro.sh
└── src/
    └── main.js

File Contents:

project-a/config.yaml:
# Sample config
key: value

project-a/data/results.txt:
Final results here.

# (Note: processed.log is not printed if only 'project-a/data' was specified,
#  but would be printed if 'project-a/data/processed.log' was explicitly specified)
```