import 'dart:io';
import 'package:balo/view/terminal.dart';

String fileRegexPattern(String pattern) => pattern.startsWith('.')
    ? r'(^|/)' + pattern.replaceFirst('.', r'\.') + r'(/|$)'
    : r'(^|/)' + pattern + r'(/|$)';

String get switchRegexPattern => r'^--|-';

bool shouldIgnorePath(String path, List<String> ignoredPatterns) {
  return ignoredPatterns.any((pattern) {
    String p = fileRegexPattern(pattern);
    return RegExp(p).hasMatch(path);
  });
}

bool shouldAddPath(String path, String pattern) {
  String p = fileRegexPattern(pattern);
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
