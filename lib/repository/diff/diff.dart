import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:isolate';
import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:dart_levenshtein/dart_levenshtein.dart';
import 'package:path/path.dart';

const maxDiffScore = 100;

class CommitDiff {
  Commit thisCommit;
  Commit otherCommit;
  List<FileDiff> filesDiff;
  Map<DiffType, int> statistic;

  CommitDiff({
    required this.filesDiff,
    required this.thisCommit,
    required this.otherCommit,
    required this.statistic,
  });

  static Future<CommitDiff> calculateDiff({
    required Commit a,
    required Commit b,
    Function()? onNoBCommitBranchMetaData,
    Function()? onNoBCommitMetaData,
    Function()? onNoACommitBranchMetaData,
    Function()? onNoACommitMetaData,
  }) async {
    //Get a commit files
    List<File>? aFiles = a.getCommitFiles(
      onNoCommitBranchMetaData: onNoACommitBranchMetaData,
      onNoCommitMetaData: onNoACommitMetaData,
    );

    //Get b commit files
    List<File>? bFiles = b.getCommitFiles(
      onNoCommitBranchMetaData: onNoBCommitBranchMetaData,
      onNoCommitMetaData: onNoBCommitMetaData,
    );

    if (aFiles == null && bFiles == null) {
      return CommitDiff(
        filesDiff: [],
        thisCommit: a,
        otherCommit: b,
        statistic: {},
      );
    }
    aFiles ??= [];
    bFiles ??= [];

    //Get b files map
    String bDirPrefix = join(b.branch.branchDirectoryPath, b.sha);
    Map<String, File> bFilesMap = {
      for (var f in bFiles) f.path.replaceAll(bDirPrefix, ""): f
    };

    //Get a files map
    String aDirPrefix = join(a.branch.branchDirectoryPath, a.sha);
    Map<String, File> aFilesMap = {
      for (var f in aFiles) f.path.replaceAll(aDirPrefix, ""): f
    };

    //Compare this with other
    debugPrintToConsole(
      message:
          "Comparing files from ${a.sha} commit (${aFiles.length} files) to ${b.sha} commit (${bFiles.length} files)",
    );

    List<FileDiff> filesDiff = [];
    Map<DiffType, int> statistics = {};
    HashSet<String> abFiles = HashSet();
    abFiles.addAll(aFilesMap.keys);
    abFiles.addAll(bFilesMap.keys);

    for (String key in abFiles) {
      File? aFile = aFilesMap[key];
      File? bFile = bFilesMap[key];

      late DiffType diffType;
      if (aFile == null) {
        diffType = DiffType.delete;
      } else if (bFile == null) {
        diffType = DiffType.insert;
      } else {
        FileDiff fileDiff = await FileDiff.calculateDiff(a: aFile, b: bFile);
        filesDiff.add(fileDiff);
        diffType = DiffType.modify;
      }

      statistics.update(diffType, (o) => o + 1, ifAbsent: () => 1);
    }

    return CommitDiff(
      filesDiff: filesDiff,
      thisCommit: a,
      otherCommit: b,
      statistic: statistics,
    );
  }

  @override
  String toString() => """
  Commit Comparison: ${thisCommit.sha} (${thisCommit.branch.branchName}) compare to ${otherCommit.sha} (${otherCommit.branch.branchName})
  Files Diff: $filesDiff
  Statistics: $statistic
  """;
}

class FileDiff {
  File thisFile;
  File otherFile;

  //From this perspective
  DiffType diffType;
  Map<int, FileLineDiff> linesDiff;

  FileDiff({
    required this.thisFile,
    required this.otherFile,
    required this.linesDiff,
    required this.diffType,
  });

  static Future<FileDiff> calculateDiff({
    required File a,
    required File b,
  }) async {
    if (!a.existsSync()) {
      return FileDiff(
        thisFile: a,
        otherFile: b,
        linesDiff: {},
        diffType: DiffType.delete,
      );
    }

    List<String> aTotalLines = a.readAsLinesSync();
    if (!b.existsSync()) {
      Map<int, FileLineDiff> linesDiff = {};
      for (int i = 0; i < aTotalLines.length; i++) {
        int lineNo = i + 1;
        linesDiff.putIfAbsent(
          lineNo,
          () => FileLineDiff(
            thisPath: a.path,
            otherPath: b.path,
            thisLineNo: lineNo,
            diffScore: maxDiffScore,
            diffType: DiffType.insert,
          ),
        );
      }

      return FileDiff(
        thisFile: a,
        otherFile: b,
        linesDiff: linesDiff,
        diffType: DiffType.insert,
      );
    }

    Map<int, FileLineDiff> linesDiff = {};
    int bLines = a.readAsLinesSync().length;
    int maxLines = max(aTotalLines.length, bLines);

    for (int i = 0; i < maxLines; i++) {
      int lineNo = i + 1;
      FileLineDiff fileLineDiff = await FileLineDiff.calculateDiff(
        a: a,
        aLineNo: lineNo,
        b: b,
      );
      linesDiff.putIfAbsent(lineNo, () => fileLineDiff);
    }

    return FileDiff(
      thisFile: a,
      otherFile: b,
      linesDiff: linesDiff,
      diffType: DiffType.modify,
    );
  }

  @override
  String toString() => """
  File Comparison: ${thisFile.path} compare to ${otherFile.path}
  Lines Diff: $linesDiff
  DiffType: $diffType
  """;
}

class FileLineDiff {
  String thisPath;
  String otherPath;

  //From this perspective
  int thisLineNo;
  int diffScore;
  DiffType diffType;

  FileLineDiff({
    required this.thisPath,
    required this.otherPath,
    required this.thisLineNo,
    required this.diffScore,
    required this.diffType,
  });

  static Future<FileLineDiff> calculateDiff({
    required File a,
    required int aLineNo,
    Function()? onALineDoesntExist,
    required File b,
  }) async {
    if (!a.existsSync()) {
      return FileLineDiff(
        thisPath: a.path,
        otherPath: b.path,
        thisLineNo: aLineNo,
        diffScore: maxDiffScore,
        diffType: DiffType.delete,
      );
    }

    List<String> aTotalLines = a.readAsLinesSync();
    if (aTotalLines.length < aLineNo) {
      onALineDoesntExist?.call();
      return FileLineDiff(
        thisPath: a.path,
        otherPath: b.path,
        thisLineNo: aLineNo,
        diffScore: maxDiffScore,
        diffType: DiffType.delete,
      );
    }
    String lineA = aTotalLines[aLineNo + 1];
    if (!b.existsSync()) {
      return FileLineDiff(
        thisPath: a.path,
        otherPath: b.path,
        thisLineNo: aLineNo,
        diffScore: maxDiffScore,
        diffType: DiffType.insert,
      );
    }

    List<String> bTotalLines = b.readAsLinesSync();
    if (bTotalLines.length < aLineNo) {
      return FileLineDiff(
        thisPath: a.path,
        otherPath: b.path,
        thisLineNo: aLineNo,
        diffScore: maxDiffScore,
        diffType: DiffType.insert,
      );
    }

    String lineB = aTotalLines[aLineNo + 1];
    if (lineB.isEmpty) {
      return FileLineDiff(
        thisPath: a.path,
        otherPath: b.path,
        thisLineNo: aLineNo,
        diffScore: maxDiffScore,
        diffType: DiffType.delete,
      );
    }

    int diffScore = await LevenshteinDistance(lineA, lineB).calculateDistance();
    return FileLineDiff(
      thisPath: a.path,
      otherPath: b.path,
      thisLineNo: aLineNo,
      diffScore: diffScore,
      diffType: DiffType.modify,
    );
  }

  @override
  String toString() => """
  File Line Comparison: $thisPath compare to $otherPath
  Line: $thisLineNo
  DiffScore: $diffScore
  DiffType: $diffType
  """;
}

enum DiffType { insert, modify, delete }

class LevenshteinDistance {
  final String lineA;
  final String lineB;

  LevenshteinDistance(this.lineA, this.lineB);

  void _calculateDistance(SendPort sendPort) async {
    lineA.levenshteinDistance(lineB).then(
          (distance) => sendPort.send(distance),
        );
  }

  Future<int> calculateDistance() async {
    // Create a ReceivePort to get data from the isolate
    final ReceivePort receivePort = ReceivePort("levenshteinDistance");

    // Spawn a new isolate
    await Isolate.spawn(_calculateDistance, receivePort.sendPort);

    // Wait for the result from the spawned isolate
    return await receivePort.first;
  }
}
