import 'dart:collection';
import 'dart:io';
import 'dart:math';
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
    required Commit thisCommit,
    required Commit otherCommit,
    Function()? onNoOtherCommitBranchMetaData,
    Function()? onNoOtherCommitMetaData,
    Function()? onNoThisCommitBranchMetaData,
    Function()? onNoThisCommitMetaData,
  }) async {
    //Get a commit files
    List<File>? thisFiles = thisCommit.getCommitFiles(
      onNoCommitBranchMetaData: onNoThisCommitBranchMetaData,
      onNoCommitMetaData: onNoThisCommitMetaData,
    );

    //Get b commit files
    List<File>? otherFiles = otherCommit.getCommitFiles(
      onNoCommitBranchMetaData: onNoOtherCommitBranchMetaData,
      onNoCommitMetaData: onNoOtherCommitMetaData,
    );

    if (thisFiles == null && otherFiles == null) {
      return CommitDiff(
        filesDiff: [],
        thisCommit: thisCommit,
        otherCommit: otherCommit,
        statistic: {},
      );
    }
    thisFiles ??= [];
    otherFiles ??= [];

    //Get other files map
    String otherDirPrefix =
        join(otherCommit.branch.branchDirectoryPath, branchCommitFolder, otherCommit.sha);
    Map<String, File> otherFilesMap = {
      for (var f in otherFiles) f.path.replaceAll(otherDirPrefix, ""): f
    };

    //Get this files map
    String thisDirPrefix =
        join(thisCommit.branch.branchDirectoryPath, branchCommitFolder, thisCommit.sha);
    Map<String, File> thisFilesMap = {
      for (var f in thisFiles) f.path.replaceAll(thisDirPrefix, ""): f
    };

    //Compare this with other
    debugPrintToConsole(
      message:
          "Comparing files from ${thisCommit.sha} commit (${thisFiles.length} files) to ${otherCommit.sha} commit (${otherFiles.length} files)",
    );

    List<FileDiff> filesDiff = [];
    Map<DiffType, int> statistics = {};
    HashSet<String> thisAndOtherFiles = HashSet();
    thisAndOtherFiles.addAll(thisFilesMap.keys);
    thisAndOtherFiles.addAll(otherFilesMap.keys);

    for (String thisOrOtherFileKey in thisAndOtherFiles) {
      debugPrintToConsole(message: thisOrOtherFileKey);

      File? thisFile = thisFilesMap[thisOrOtherFileKey];
      File? otherFile = otherFilesMap[thisOrOtherFileKey];

      late DiffType diffType;
      if (thisFile == null) {
        diffType = DiffType.delete;
      } else if (otherFile == null) {
        diffType = DiffType.insert;
      } else {
        FileDiff fileDiff = await FileDiff.calculateDiff(thisFile: thisFile, otherFile: otherFile);
        filesDiff.add(fileDiff);
        diffType = DiffType.modify;
      }

      statistics.update(diffType, (o) => o + 1, ifAbsent: () => 1);
    }

    return CommitDiff(
      filesDiff: filesDiff,
      thisCommit: thisCommit,
      otherCommit: otherCommit,
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
    required File thisFile,
    required File otherFile,
  }) async {
    if (!thisFile.existsSync()) {
      return FileDiff(
        thisFile: thisFile,
        otherFile: otherFile,
        linesDiff: {},
        diffType: DiffType.delete,
      );
    }

    List<String> thisTotalLines = thisFile.readAsLinesSync();
    if (!otherFile.existsSync()) {
      Map<int, FileLineDiff> linesDiff = {};
      for (int i = 0; i < thisTotalLines.length; i++) {
        int lineNo = i + 1;
        linesDiff.putIfAbsent(
          lineNo,
          () => FileLineDiff(
            thisPath: thisFile.path,
            otherPath: otherFile.path,
            thisLineNo: lineNo,
            diffScore: maxDiffScore,
            diffType: DiffType.insert,
          ),
        );
      }

      return FileDiff(
        thisFile: thisFile,
        otherFile: otherFile,
        linesDiff: linesDiff,
        diffType: DiffType.insert,
      );
    }

    Map<int, FileLineDiff> linesDiff = {};
    int otherLines = otherFile.readAsLinesSync().length;
    int maxLines = max(thisTotalLines.length, otherLines);

    for (int lineNo = 0; lineNo < maxLines; lineNo++) {
      FileLineDiff fileLineDiff = await FileLineDiff.calculateDiff(
        thisFile: thisFile,
        thisLineNo: lineNo,
        otherFile: otherFile,
      );
      linesDiff.putIfAbsent(lineNo, () => fileLineDiff);
    }

    return FileDiff(
      thisFile: thisFile,
      otherFile: otherFile,
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
    required File thisFile,
    required int thisLineNo,
    Function()? onThisLineDoesntExist,
    required File otherFile,
  }) async {
    if (!thisFile.existsSync()) {
      return FileLineDiff(
        thisPath: thisFile.path,
        otherPath: otherFile.path,
        thisLineNo: thisLineNo,
        diffScore: maxDiffScore,
        diffType: DiffType.delete,
      );
    }

    List<String> thisTotalLines = thisFile.readAsLinesSync();
    if (thisLineNo > thisTotalLines.length - 1) {
      onThisLineDoesntExist?.call();
      return FileLineDiff(
        thisPath: thisFile.path,
        otherPath: otherFile.path,
        thisLineNo: thisLineNo,
        diffScore: maxDiffScore,
        diffType: DiffType.delete,
      );
    }
    String thisLine = thisTotalLines[thisLineNo];
    if (!otherFile.existsSync()) {
      return FileLineDiff(
        thisPath: thisFile.path,
        otherPath: otherFile.path,
        thisLineNo: thisLineNo,
        diffScore: maxDiffScore,
        diffType: DiffType.insert,
      );
    }

    List<String> otherTotalLines = otherFile.readAsLinesSync();
    if (thisLineNo > otherTotalLines.length - 1) {
      return FileLineDiff(
        thisPath: thisFile.path,
        otherPath: otherFile.path,
        thisLineNo: thisLineNo,
        diffScore: maxDiffScore,
        diffType: DiffType.insert,
      );
    }

    String otherLine = otherTotalLines[thisLineNo];
    int diffScore = await levenshteinDistance(thisLine, otherLine);

    return FileLineDiff(
      thisPath: thisFile.path,
      otherPath: otherFile.path,
      thisLineNo: thisLineNo,
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
  final String thisLine;
  final String otherLine;

  LineComparison({
    required this.key,
    required this.thisLine,
    required this.otherLine,
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
