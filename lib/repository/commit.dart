import 'dart:io';

import 'package:balo/repository/branch.dart';

class Commit {
  final String sha;
  final String message;
  final Branch branch;
  final DateTime commitedAt;
  final List<File> commitedFiles;

  Commit(
    this.sha,
    this.message,
    this.branch,
    this.commitedAt,
    this.commitedFiles,
  );
}
