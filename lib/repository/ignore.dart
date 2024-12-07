import 'dart:io';

import 'package:balo/repository/repository.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';

class Ignore {
  final Repository repository;

  Ignore(this.repository);
}

extension IgnoreCommons on Ignore {
  //TODO: Move ignore file to root dir
  File get ignoreFile => File(
        join(
          repository.repositoryDirectory.path,
          repositoryIgnoreFileName,
        ),
      );

  List<String> get patternsToIgnore =>
      ignoreFile.existsSync() ? ignoreFile.readAsLinesSync().where((p) => p.isNotEmpty && !p.startsWith("#")).toList() : [];
}

extension IgnoreActions on Ignore {
  Future<void> createIgnoreFile({
    Function()? onAlreadyExists,
    Function()? onSuccessfullyCreated,
    Function()? onRepositoryNotInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onRepositoryNotInitialized?.call();
        return;
      }

      if (ignoreFile.existsSync()) {
        onAlreadyExists?.call();
        return;
      }

      await ignoreFile.create(recursive: true, exclusive: true);
      onSuccessfullyCreated?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> deleteIgnoreFile({
    Function()? onDoesntExists,
    Function()? onSuccessfullyDeleted,
    Function()? onRepositoryNotInitialized,
    Function(FileSystemException)? onFileSystemException,
  }) async {
    try {
      if (!repository.isInitialized) {
        onRepositoryNotInitialized?.call();
        return;
      }

      if (!ignoreFile.existsSync()) {
        onDoesntExists?.call();
        return;
      }

      await ignoreFile.delete(recursive: true);
      onSuccessfullyDeleted?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> addIgnore({
    required String pattern,
    Function()? onAlreadyPresent,
    Function()? onAdded,
    Function(FileSystemException)? onFileSystemException,
  }) async {
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
      );

      onAdded?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
  }

  Future<void> removeIgnore({
    required String pattern,
    Function()? onNotFoundPresent,
    Function()? onRemoved,
    Function(FileSystemException)? onFileSystemException,
  }) async {
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
      );

      onRemoved?.call();
    } on FileSystemException catch (e, trace) {
      onFileSystemException?.call(e);
    }
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

  /// Convert patterns to valid regex
  // "*" -> ".*"
  // "?" -> "."
  // "**" -> ".*" (handles nested directories)
  // "/" -> "/" (directly uses slash for path match)
  String get regex => filePatternToRegex(pattern);
}
