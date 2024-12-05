import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/diff/diff.dart';

String regexPattern(String pattern) => pattern.startsWith('.')
    ? r'(^|/)' + pattern.replaceFirst('.', r'\.') + r'(/|$)'
    : r'(^|/)' + pattern + r'(/|$)';

bool shouldIgnorePath(String path, List<String> ignoredPatterns) {
  return ignoredPatterns.any((pattern) {
    String p = regexPattern(pattern);
    return RegExp(p).hasMatch(path);
  });
}

bool shouldAddPath(String path, String pattern) {
  String p = regexPattern(pattern);
  return RegExp(p).hasMatch(path);
}

void moveFiles({
  required List<File> files,
  required Directory sourceDir,
  required Directory destinationDir,
}) {
  printToConsole(
      message:
          "moving ${files.length}  files from ${sourceDir.path} to ${destinationDir.path}");

  for (File sourceFile in files) {
    String fileDestinationPath = sourceFile.path.replaceAll(
      sourceDir.path,
      destinationDir.path,
    );

    File destinationFile = File(fileDestinationPath);
    destinationFile.createSync(recursive: true);
    destinationFile.writeAsBytesSync(
      sourceFile.readAsBytesSync(),
      mode: FileMode.writeOnly,
      flush: true,
    );

    debugPrintToConsole(message: "mv ${sourceFile.path} -> $fileDestinationPath");
  }
}
