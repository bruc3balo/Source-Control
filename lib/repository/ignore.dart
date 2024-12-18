import 'dart:io';

import 'package:balo/repository/repository.dart';
import 'package:balo/utils/print_fn.dart';
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
  void addIgnore(
    String pattern, {
    Function()? onAlreadyPresent,
    Function()? onAdded,
  }) {
    List<String> ignores = ignoreFile.readAsLinesSync();
    if (ignores.contains(pattern)) {
      onAlreadyPresent?.call();
      return;
    }

    ignores.add(pattern);

    ignoreFile
      ..createSync(recursive: true)
      ..writeAsStringSync(
        ignores.join(Platform.lineTerminator),
        flush: true,
        mode: FileMode.write,
      );

    onAdded?.call();
  }

  /// Remove a [pattern] from the [ignoreFile]
  void removeIgnore({
    required String pattern,
    Function()? onNotFoundPresent,
    Function()? onRemoved,
  }) {
    List<String> ignores = ignoreFile.readAsLinesSync();
    if (!ignores.contains(pattern)) {
      onNotFoundPresent?.call();
      return;
    }

    ignores.remove(pattern);

    ignoreFile
      ..createSync(recursive: true)
      ..writeAsStringSync(
        ignores.join(Platform.lineTerminator),
        flush: true,
        mode: FileMode.write,
      );

    onRemoved?.call();
  }
}

extension IgnoreActions on Ignore {
  /// Creates an [ignoreFile]
  void createIgnoreFile({
    Function()? onAlreadyExists = onIgnoreFileAlreadyExists,
    Function()? onSuccessfullyCreated = onIgnoreFileSuccessfullyCreated,
    Function()? onRepositoryNotInitialized = onRepositoryNotInitialized,
  }) {
    if (!repository.isInitialized) {
      debugPrintToConsole(
        message: "Repository not initialized",
      );
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
    Function()? onDoesntExists = onIgnoreFileDoesntExists,
    Function()? onSuccessfullyDeleted = onIgnoreFileSuccessfullyDeleted,
    Function()? onRepositoryNotInitialized = onRepositoryNotInitialized,
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

    debugPrintToConsole(message: "Detected rule $rule for test pattern $testPattern \n", newLine: true);

    for (String inputPattern in passInputPatterns) {
      bool pass = rule.patternMatches(testPattern: testPattern, inputPattern: inputPattern);
      CliColor color = pass ? CliColor.green : CliColor.red;
      debugPrintToConsole(message: "Pass Test: input $inputPattern = $pass", color: color);
      assert(pass);
    }

    for (String inputPattern in failInputPatterns) {
      bool pass = rule.patternMatches(testPattern: testPattern, inputPattern: inputPattern);
      CliColor color = !pass ? CliColor.green : CliColor.red;
      debugPrintToConsole(message: "Fail Test: input $inputPattern = $pass", color: color);
      assert(!pass);
    }
  }
}

enum IgnorePatternRules {
  // matches any number of characters
  suffix(
    position: PatternPosition.start,
    description: "Matches any number of characters",
  ),
  // matches a single character
  single(
    position: PatternPosition.any,
    description: "Matches exactly one character",
  ),
  // matches nested directories
  contains(
    position: PatternPosition.any,
    description: "Matches nested directories",
  ),
  // at start means relative to the root
  pathFromRoot(
    position: PatternPosition.start,
    description: "Relative to root start",
  ),
  // at start means relative to the root
  exactMatch(
    position: PatternPosition.any,
    description: "Exact name match",
  );

  final PatternPosition position;
  final String description;

  const IgnorePatternRules({
    required this.position,
    required this.description,
  });

  String get pattern => switch (this) {
        IgnorePatternRules.suffix => "*",
        IgnorePatternRules.single => "?",
        IgnorePatternRules.contains => "**",
        IgnorePatternRules.pathFromRoot => Platform.pathSeparator,
        IgnorePatternRules.exactMatch => "",
      };

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

extension IgnorePatternRulesEvaluator on IgnorePatternRules {
  PatternExamples get example => switch (this) {
        IgnorePatternRules.suffix => PatternExamples(
            testPattern: "*.log",
            passInputPatterns: ["app.log", "system.log", "error.log"],
            failInputPatterns: ["log", ".log", "file.txt"],
          ),
        IgnorePatternRules.single => PatternExamples(
            testPattern: "file?.txt",
            passInputPatterns: ["file1.txt", "fileA.txt", "file_.txt", "files.txt"],
            failInputPatterns: ["file.txt", "file12.txt"],
          ),
        IgnorePatternRules.contains => PatternExamples(
            testPattern: "**/build/**",
            passInputPatterns: [
              "project/build/file.txt",
              "/build/subdir/file.txt",
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
        return inputPattern.endsWith(parsedPattern) && inputPattern.replaceFirst(parsedPattern, "").isNotEmpty;

      case IgnorePatternRules.single:
        if (testPattern.length != inputPattern.length) return false;

        String parsedPattern = testPattern.replaceAll(pattern, "");
        String parsedInput = "";

        //Replace with empty string and match the strings
        for (int i = 0; i < testPattern.length; i++) {
          String testPatternChar = testPattern[i];

          //skip character
          if (testPatternChar == pattern) continue;
          parsedInput += testPatternChar;
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
