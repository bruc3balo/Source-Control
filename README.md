# 0: source control system

Build a distributed source control system in the style of Git. It should be possible to initialise a repository in a directory and the repository proper should be stored in a dot-prefixed subdirectory. There should be support for staging files (git add) and committing them. There should be a way to view the commit history, to create branches, merge and do diffs between them. Conflicting changes should be detected but there's no need to build resolution features for them, or anything like rebasing. It should also be possible to clone the repository (on disk—it doesn't have to work over network). Finally, there should be a way to ignore files.


# Design Patterns
- Commands have been done with the **Command Design Pattern**
- The inputs parsed into a list commands with the **Facade** pattern



# Build

## For Windows: 
```bash

dart compile exe bin/balo.dart -o build/windows/balo.exe --target-os=windows

```
## For macOS: 
```bash

dart compile exe bin/balo.dart -o build/macos/balo --target-os=macos

```
## For Linux:
```bash

dart compile exe bin/balo.dart -o build/linux/balo --target-os=linux

```

# Running

## With dart
```bash

dart run bin/balo.dart

```

## Binary
```bash

dart run bin/balo.dart

```