import 'dart:io';

import 'package:balo/repository/repository.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';

///Represents an ignore file in memory
class Ignore {
  final Repository repository;

  Ignore(this.repository);
}

extension IgnoreCommons on Ignore {
  /// Path to [ignoreFile]
  String get ignoreFilePath => join(repository.repositoryDirectory.path, repositoryIgnoreFileName);

  /// Actual file for the [Ignore]
  File get ignoreFile => File(ignoreFilePath);

  /// Extracts patterns to ignore from [ignoreFile]
  List<String> get patternsToIgnore =>
      ignoreFile.existsSync() ? ignoreFile.readAsLinesSync().where((p) => p.isNotEmpty && !p.startsWith("#")).toList() : [];
}

extension IgnoreStorage on Ignore {

  /// Adds a [pattern] to an [ignoreFile]
  void addIgnore({
    required String pattern,
    Function()? onAlreadyPresent,
    Function()? onAdded,
    Function(FileSystemException)? onFileSystemException,
  }) {
    try {
      List<String> ignores = ignoreFile.readAsLinesSync();
      if (ignores.contains(pattern)) {
        onAlreadyPresent?.call();
        return;
      }

      ignores.add(pattern);

      ignoreFile.writeAsStringSync(
        ignores.join(Platform.lineTerminator),
        flush: true,
        mode: FileMode.writeOnly,
      );

      onAdded?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  /// Remove a [pattern] from the [ignoreFile]
  void removeIgnore({
    required String pattern,
    Function()? onNotFoundPresent,
    Function()? onRemoved,
    Function(FileSystemException)? onFileSystemException,
  }) {
    try {
      List<String> ignores = ignoreFile.readAsLinesSync();
      if (!ignores.contains(pattern)) {
        onNotFoundPresent?.call();
        return;
      }

      ignores.remove(pattern);

      ignoreFile.writeAsStringSync(
        ignores.join(Platform.lineTerminator),
        flush: true,
        mode: FileMode.writeOnly,
      );

      onRemoved?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }
}

extension IgnoreActions on Ignore {

  /// Creates an [ignoreFile]
  void createIgnoreFile({
    Function()? onAlreadyExists,
    Function()? onSuccessfullyCreated,
    Function()? onRepositoryNotInitialized,
  }) {
    if (!repository.isInitialized) {
      onRepositoryNotInitialized?.call();
      return;
    }

    if (ignoreFile.existsSync()) {
      onAlreadyExists?.call();
      return;
    }

    ignoreFile.createSync(recursive: true, exclusive: true);
    onSuccessfullyCreated?.call();
  }

  /// Deletes an [ignoreFile]
  void deleteIgnoreFile({
    Function()? onDoesntExists,
    Function()? onSuccessfullyDeleted,
    Function()? onRepositoryNotInitialized,
  }) {
    if (!repository.isInitialized) {
      onRepositoryNotInitialized?.call();
      return;
    }

    if (!ignoreFile.existsSync()) {
      onDoesntExists?.call();
      return;
    }

    ignoreFile.deleteSync(recursive: true);
    onSuccessfullyDeleted?.call();
  }

}

///Ignore patterns
enum PatternPosition {
  any,
  start,
  mid,
  end;
}

class PatternExamples {
  final String testPattern;
  final List<String> passInputPatterns;
  final List<String> failInputPatterns;

  const PatternExamples({
    required this.testPattern,
    required this.passInputPatterns,
    required this.failInputPatterns,
  });

  void test() {
    IgnorePatternRules rule = IgnorePatternRules.detectRule(testPattern);

    for(String inputPattern in passInputPatterns) {
      bool pass = rule.patternMatches(testPattern: testPattern, inputPattern: inputPattern);
      assert(pass);
    }

    for(String inputPattern in failInputPatterns) {
      bool pass = rule.patternMatches(testPattern: testPattern, inputPattern: inputPattern);
      assert(!pass);
    }
  }
}

enum IgnorePatternRules {
  // matches any number of characters
  suffix(
    pattern: "*",
    position: PatternPosition.start,
    description: "Matches any number of characters",
  ),
  // matches a single character
  single(
    pattern: "?",
    position: PatternPosition.any,
    description: "Matches exactly one character",
  ),
  // matches nested directories
  contains(
    pattern: "**",
    position: PatternPosition.any,
    description: "Matches nested directories",
  ),
  // at start means relative to the root
  pathFromRoot(
    pattern: "/",
    position: PatternPosition.start,
    description: "Relative to root start",
  ),
  // at start means relative to the root
  exactMatch(
    pattern: "",
    position: PatternPosition.any,
    description: "Exact name match",
  );

  final String pattern;
  final PatternPosition position;
  final String description;

  const IgnorePatternRules({
    required this.pattern,
    required this.position,
    required this.description,
  });

  static IgnorePatternRules detectRule(String pattern) {
    if (pattern.startsWith(IgnorePatternRules.suffix.pattern) && !pattern.contains(IgnorePatternRules.contains.pattern)) {
      return IgnorePatternRules.suffix;
    }

    if (pattern.contains(IgnorePatternRules.single.pattern)) return IgnorePatternRules.single;

    if (pattern.contains(IgnorePatternRules.contains.pattern)) return IgnorePatternRules.contains;

    if (pattern.startsWith(IgnorePatternRules.pathFromRoot.pattern)) return IgnorePatternRules.pathFromRoot;

    return IgnorePatternRules.exactMatch;
  }
}

extension IgnorePatternRulesExaluator on IgnorePatternRules {
  PatternExamples get example => switch (this) {
        IgnorePatternRules.suffix => PatternExamples(
            testPattern: "*.log",
            passInputPatterns: ["app.log", "system.log", "error.log"],
            failInputPatterns: ["log", ".log", "file.txt"],
          ),
        IgnorePatternRules.single => PatternExamples(
            testPattern: "file?.txt",
            passInputPatterns: ["file1.txt", "fileA.txt", "file_.txt"],
            failInputPatterns: ["file.txt", "file12.txt", "files.txt"],
          ),
        IgnorePatternRules.contains => PatternExamples(
            testPattern: "**/build/**",
            passInputPatterns: [
              "project/build/file.txt",
              "build/subdir/file.txt",
              "project/subproject/build/file.txt",
            ],
            failInputPatterns: [
              "buildfile",
              "build.txt",
            ],
          ),
        IgnorePatternRules.pathFromRoot => PatternExamples(
            testPattern: "/todo.txt",
            passInputPatterns: ["/todo.txt"],
            failInputPatterns: ["project/todo.txt", "subdir/todo.txt"],
          ),
        IgnorePatternRules.exactMatch => PatternExamples(
            testPattern: "meta.json",
            passInputPatterns: ["meta.json"],
            failInputPatterns: ["/dir/meta.json", "*.json"],
          ),
      };

  ///Checks if [testPattern] matches an [inputPattern]
  ///[testPattern] may for example be a [pattern]
  bool patternMatches({
    required String testPattern,
    required String inputPattern,
  }) {
    // Simple match check for rule patterns like "*", "?", "**", etc.
    switch (this) {
      case IgnorePatternRules.suffix:
        String parsedPattern = testPattern.replaceFirst(pattern, "");
        return inputPattern.endsWith(parsedPattern);

      case IgnorePatternRules.single:
        String parsedPattern = testPattern.replaceAll(pattern, "");
        String parsedInput = "";

        //Replace with empty string and match the strings
        for (int i = 0; i < testPattern.length; i++) {
          String test = testPattern[i];
          if (test == pattern) continue;
          parsedInput += inputPattern[i];
        }

        return parsedPattern == parsedInput;

      case IgnorePatternRules.contains:
        String parsedPattern = testPattern.replaceAll(pattern, "");
        return inputPattern.contains(parsedPattern);

      case IgnorePatternRules.pathFromRoot:
        return inputPattern.startsWith(testPattern);
      case IgnorePatternRules.exactMatch:
        return testPattern == inputPattern;
    }
  }
}
