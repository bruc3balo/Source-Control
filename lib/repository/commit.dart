import 'package:balo/repository/branch/branch.dart';

class Commit {
  final Branch branch;
  final String sha;
  final String message;
  final DateTime commitedAt;

  Commit(
    this.sha,
    this.branch,
    this.message,
    this.commitedAt,
  );
}

extension CommitActions on Commit {

}
