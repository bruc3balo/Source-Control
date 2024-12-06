import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:isolate';
import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
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
    String bDirPrefix =
        join(b.branch.branchDirectoryPath, branchCommitFolder, b.sha);
    Map<String, File> bFilesMap = {
      for (var f in bFiles) f.path.replaceAll(bDirPrefix, ""): f
    };

    //Get a files map
    String aDirPrefix =
        join(a.branch.branchDirectoryPath, branchCommitFolder, a.sha);
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
      debugPrintToConsole(message: key);

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
  Files: ${filesDiff.length}
  Statistics: ${statistic.entries.map((e) => "${e.key.name} ${e.value}").join()}
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
    int bLines = b.readAsLinesSync().length;
    int maxLines = max(aTotalLines.length, bLines);

    for (int lineNo = 0; lineNo < maxLines; lineNo++) {
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
  \n  File Comparison: (a) ${basename(thisFile.path)} compare to (b) ${basename(otherFile.path)}
  Lines Diff: ${linesDiff.entries.map((e) => e.value.toString()).join()}
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
    if (aLineNo > aTotalLines.length - 1) {
      onALineDoesntExist?.call();
      return FileLineDiff(
        thisPath: a.path,
        otherPath: b.path,
        thisLineNo: aLineNo,
        diffScore: maxDiffScore,
        diffType: DiffType.delete,
      );
    }
    String lineA = aTotalLines[aLineNo];
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
    if (aLineNo > bTotalLines.length - 1) {
      return FileLineDiff(
        thisPath: a.path,
        otherPath: b.path,
        thisLineNo: aLineNo,
        diffScore: maxDiffScore,
        diffType: DiffType.insert,
      );
    }

    String lineB = bTotalLines[aLineNo];
    int diffScore = await levenshteinDistance(lineA, lineB);

    return FileLineDiff(
      thisPath: a.path,
      otherPath: b.path,
      thisLineNo: aLineNo,
      diffScore: diffScore,
      diffType: diffScore == 0 ? DiffType.same : DiffType.modify,
    );
  }

  @override
  String toString() => """
  \n  Line: $thisLineNo
  DiffScore: $diffScore
  DiffType: $diffType
  """;
}

enum DiffType { insert, modify, delete, same }

extension DiffTypeColor on DiffType {
  CliColor get color => switch (this) {
        DiffType.insert => CliColor.brightGreen,
        DiffType.modify => CliColor.brightWhite,
        DiffType.delete => CliColor.brightRed,
        DiffType.same => CliColor.yellow,
      };

  String get title => switch (this) {
        DiffType.insert => "inserted",
        DiffType.modify => "modified",
        DiffType.delete => "deleted",
        DiffType.same => "same",
      };
}


class LineComparison {
  final String key;
  final String lineA;
  final String lineB;

  LineComparison({
    required this.key,
    required this.lineA,
    required this.lineB,
  });
}

extension CommitDiffPrint on CommitDiff {
  void fullPrint() {
    printDiff();

    for (var a in filesDiff) {
      a.printDiff();

      for (var b
          in a.linesDiff.values.where((e) => e.diffType != DiffType.same)) {
        b.printDiff();
      }
    }
  }

  void printDiff() {
    printToConsole(
      message: "Commits: a -> ${thisCommit.sha}, b -> ${otherCommit.sha}",
      color: CliColor.brightMagenta,
      style: CliStyle.bold,
      newLine: true,
    );

    printToConsole(
      message: "Files ${filesDiff.length}",
      color: CliColor.blue,
    );

    printToConsole(
      message:
          "Statistics: ${statistic.entries.map((e) => "${e.key.color.color}${e.key.title} ${e.value}${CliColor.defaultColor.color}").join()}",
      color: CliColor.blue,
    );
  }
}

extension FileDiffPrint on FileDiff {
  Map<DiffType, int> get diffCount {
    Map<DiffType, int> count = {};

    for (var d in linesDiff.values) {
      count.update(d.diffType, (p) => p + 1, ifAbsent: () => 1);
    }

    return count;
  }

  void printDiff() {
    int differences = diffCount.entries
        .where((e) => e.key != DiffType.same)
        .map((e) => e.value)
        .fold(0, (a, b) => a + b);
    printToConsole(
      message:
          "Files: a -> ${basename(thisFile.path)}, b -> ${basename(otherFile.path)} = ${diffType.title} ($differences difference${differences == 1 ? '' : 's'})",
      color: CliColor.brightBlue,
      style: CliStyle.bold,
      newLine: true,
    );
    printToConsole(
      message:
          "${DiffType.insert.color.color} ++inserted ${diffCount[DiffType.insert] ?? 0} ${CliColor.defaultColor.color} ${DiffType.delete.color.color}--deleted ${diffCount[DiffType.delete] ?? 0}${CliColor.defaultColor.color} ${DiffType.modify.color.color} **modified ${diffCount[DiffType.modify] ?? 0}${CliColor.defaultColor.color}",
      color: DiffType.insert.color,
    );
  }
}

extension FileLineDiffPrint on FileLineDiff {
  void printDiff() {
    printToConsole(
      message:
          "Line@$thisLineNo: a -> ${basename(thisPath)}, b -> ${basename(otherPath)} = ${diffType.color.color}${diffType.name} ${diffType == DiffType.modify ? '($diffScore)' : ''}${CliColor.defaultColor.color}",
      color: diffType.color,
      style: CliStyle.bold,
    );
  }
}
