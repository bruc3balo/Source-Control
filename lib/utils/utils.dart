import 'dart:io';
import 'package:balo/repository/ignore.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';

String filePatternToRegex(String pattern) {
  return pattern.replaceAll('.', r'\.').replaceAll('**', r'.*').replaceAll('*', r'[^/]*').replaceAll('?', r'[^/]');
}



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

void copyFiles({
  required List<File> files,
  required Directory sourceDir,
  required Directory destinationDir,
}) {
  printToConsole(message: "copying ${files.length} files from ${sourceDir.path} to ${destinationDir.path}");

  for (File sourceFile in files) {
    String fileDestinationPath = sourceFile.path.replaceAll(
      sourceDir.path,
      destinationDir.path,
    );

    File(fileDestinationPath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(
        sourceFile.readAsBytesSync(),
        mode: FileMode.writeOnly,
        flush: true,
      );

    debugPrintToConsole(message: "cp ${sourceFile.path} -> $fileDestinationPath");
  }
}
