# 0: source control system [![wakatime](https://wakatime.com/badge/user/e508bec6-f1ed-42e9-a365-8c4e69c8dd19/project/bff0792d-4b5a-4003-98b3-d9e75973114d.svg)](https://wakatime.com/badge/user/e508bec6-f1ed-42e9-a365-8c4e69c8dd19/project/bff0792d-4b5a-4003-98b3-d9e75973114d)


Build a distributed source control system in the style of Git. It should be possible to initialise a repository in a directory and the repository proper should be stored in a dot-prefixed subdirectory. There should be support for staging files (git add) and committing them. There should be a way to view the commit history, to create branches, merge and do diffs between them. Conflicting changes should be detected but there's no need to build resolution features for them, or anything like rebasing. It should also be possible to clone the repository (on disk—it doesn't have to work over network). Finally, there should be a way to ignore files.

# Design Patterns
- Commands have been done with the **Command Design Pattern**
- The inputs parsed into a Command Facade running a list of commands with the **Facade** pattern

# Documentation generation
```bash
    dart doc
```
Run documentation [locally](http://localhost:8080/index.html)
```bash
    dart doc/doc_server.dart
```

# Code generation
```bash
  dart run build_runner build --delete-conflicting-outputs
```

# Test
Test in isolation
```bash
  dart run test --concurrency=1
```

# Build
#### For Windows: 
```bash
  dart compile exe bin/balo.dart -o build/windows/balo.exe --target-os=windows
```
#### For macOS: 
```bash
  dart compile exe bin/balo.dart -o build/macos/balo --target-os=macos
```
#### For Linux:
```bash
  dart compile exe bin/balo.dart -o build/linux/balo --target-os=linux
```

# Running

### Dart
```bash
  dart run bin/balo.dart
```

### Binary
#### For Windows:
```bash
  ./build/windows/balo
```
### For macOS:
```bash
  ./build/macos/balo
```
### For Linux:
```bash
   ./build/linux/balo
```

# Installing Options

### For dart
```bash
    dart pub global activate --source path .
```

#### For Windows:
- Copy to System32
```bash
  copy .\build\windows\balo.exe C:\Windows\System32\balo.exe
```

- Create symlink to System32
```bash
  mklink C:\Windows\System32\balo.exe .\build\windows\balo.exe 
```

#### For macOS:
- Copy to local bin directory
```bash
  sudo cp ./build/macos/balo /usr/local/bin/balo && sudo chmod +x /usr/local/bin/balo
```
- Create symlink to local bin directory
```bash
  sudo ln -s ./build/macos/balo /usr/local/bin/balo 
```

#### For Linux:
- Copy to local bin directory
```bash
   sudo cp ./build/linux/balo /usr/local/bin
```

- Create symlink to local bin directory
```bash
    sudo ln -s ./build/linux/balo /usr/local/bin/balo
```


