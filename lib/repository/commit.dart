import 'dart:io';

import 'package:balo/repository/branch.dart';

class Commit {
  final Branch branch;
  final String sha;

  Commit(
    this.sha,
    this.branch,
  );
}

extension CommitActions on Commit {


}
