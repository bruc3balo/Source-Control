import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

///[Function] to validate a [Branch] name and takes a [branchName]
bool isValidBranchName(String? branchName) {
  // Check if the branch name is null or empty
  if (branchName == null || branchName.isEmpty) {
    return false;
  }

  // branch should contain spaces
  if (branchName.contains(" ")) {
    return false;
  }

  // branch should not start with a dot
  if (branchName.startsWith(".")) {
    return false;
  }

  return true;
}

///Sha1 algorithm on a [Commit]
Sha1 createCommitSha({
  required String branchName,
  required String message,
  required int noOfObjects,
  required DateTime commitedAt,
}) {
  return computeSha1Hash(
    utf8.encode(
      [branchName, message, noOfObjects, commitedAt].join(),
    ),
  );
}

///Creates a [Sha1] from a [file]
Sha1 computeFileSha1Hash(File file) => computeSha1Hash(file.readAsBytesSync());

///Creates a [Sha1] hash from [bytes] data
Sha1 computeSha1Hash(Uint8List bytes) => Sha1(sha1.convert(bytes).toString());

///Strips leading [pathSeparator] from [path] if exists
String stripBeginningPathSeparatorPath(String path, {String? pathSeparator}) => path.startsWith(pathSeparator ?? Platform.pathSeparator) ? path.replaceFirst(pathSeparator ?? Platform.pathSeparator, "") : path;

/// Returns a relative path from a [directoryPath] for [path]
String relativePathFromDir({ required String directoryPath, required String path}) => path.replaceAll(directoryPath, "");

/// Attaches a [relativePath] to a [directoryPath]
String fullPathFromDir({required String relativePath, required String directoryPath}) => join(
      directoryPath,
      stripBeginningPathSeparatorPath(relativePath),
    );

///[path] starts with [Platform.pathSeparator] as a relative path from the [Repository]parent dir
bool shouldAddPath(String path, {String pattern = star}) {
  debugPrintToConsole(message: "Checking if should add Path: $path", newLine: true);
  debugPrintToConsole(message: "Pattern: $pattern");

  if (pattern == dot || pattern == star || pattern.isEmpty) return true;

  final IgnorePatternRules rule = IgnorePatternRules.detectRule(pattern);
  final bool matched = switch (rule) {
    IgnorePatternRules.pathFromRoot => rule.patternMatches(
      testPattern: pattern,
      inputPattern: path,
    ),
    IgnorePatternRules.suffix => rule.patternMatches(
      testPattern: pattern,
      inputPattern: path,
    ),
    IgnorePatternRules.single => rule.patternMatches(
      testPattern: pattern,
      inputPattern: stripBeginningPathSeparatorPath(path),
    ),
    IgnorePatternRules.contains => rule.patternMatches(
      testPattern: pattern,
      inputPattern: path,
    ),
    IgnorePatternRules.exactMatch => rule.patternMatches(
      testPattern: pattern,
      inputPattern: stripBeginningPathSeparatorPath(path),
    ),
  };

  debugPrintToConsole(message: "Result: $matched");
  debugPrintToConsole(message: "Description: Pattern matched $matched against $rule");

  return matched;
}

///[path] starts with [Platform.pathSeparator] as a relative path from the [Repository] parent dir
bool shouldIgnorePath(String path, List<String> ignoredPatterns) {
  debugPrintToConsole(message: "Checking if should ignore $path", newLine: true);

  for (String ignorePattern in ignoredPatterns) {
    IgnorePatternRules rule = IgnorePatternRules.detectRule(ignorePattern);

    final bool matched = switch (rule) {
      IgnorePatternRules.pathFromRoot => rule.patternMatches(
        testPattern: ignorePattern,
        inputPattern: path,
      ),
      IgnorePatternRules.suffix => rule.patternMatches(
        testPattern: ignorePattern,
        inputPattern: path,
      ),
      IgnorePatternRules.single => rule.patternMatches(
        testPattern: ignorePattern,
        inputPattern: stripBeginningPathSeparatorPath(path),
      ),
      IgnorePatternRules.contains => rule.patternMatches(
        testPattern: ignorePattern,
        inputPattern: path,
      ),
      IgnorePatternRules.exactMatch => rule.patternMatches(
        testPattern: ignorePattern,
        inputPattern: stripBeginningPathSeparatorPath(path),
      ),
    };

    if (matched) {
      debugPrintToConsole(message: "$path will be ignored due to match by $rule on $ignorePattern");
      return true;
    }
  }

  debugPrintToConsole(message: "$path will not be ignored");
  return false;
}