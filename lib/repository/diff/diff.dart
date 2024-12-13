import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/utils/print_fn.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';


///Represents differences of 2 [Commit]s in memory
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
    Function(Branch)? onNoOtherCommitBranchMetaData = onNoCommitBranchMetaData,
    Function(Commit)? onNoOtherCommitMetaData = onNoCommitMetaData,
    Function(Branch)? onNoThisCommitBranchMetaData = onNoCommitBranchMetaData,
    Function(Commit)? onNoThisCommitMetaData = onNoCommitMetaData,
  }) async {
    //Get a commit files
    Map<String, RepoObjectsData>? thisFiles = thisCommit.getCommitFiles(
      onNoCommitMetaData: onNoThisCommitMetaData,
      onNoCommitBranchMetaData: onNoThisCommitBranchMetaData,
    );

    //Get b commit files
    Map<String, RepoObjectsData>? otherFiles = otherCommit.getCommitFiles(
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
    thisFiles ??= {};
    otherFiles ??= {};

    //Compare this with other
    debugPrintToConsole(
      message:
          "Comparing files from ${thisCommit.sha.hash} commit (${thisFiles.length} files) to ${otherCommit.sha.hash} commit (${otherFiles.length} files)",
    );

    List<FileDiff> filesDiff = [];
    Map<DiffType, int> statistics = {};
    HashSet<String> thisAndOtherFiles = HashSet();
    thisAndOtherFiles.addAll(thisFiles.keys);
    thisAndOtherFiles.addAll(otherFiles.keys);

    Directory tempDirectory = Directory.systemTemp.createTempSync();

    for (String thisOrOtherFileSha in thisAndOtherFiles) {
      debugPrintToConsole(message: thisOrOtherFileSha);

      RepoObjectsData? thisObject = thisFiles[thisOrOtherFileSha];
      RepoObjectsData? otherObject = otherFiles[thisOrOtherFileSha];

      debugPrintToConsole(message: "Comparing", newLine: true);
      debugPrintToConsole(message: "This: -> ${thisObject?.fileName} & sha -> ${thisObject?.sha}", color: CliColor.cyan);
      debugPrintToConsole(message: "Other: -> ${otherObject?.fileName} & sha -> ${otherObject?.sha}", color: CliColor.cyan);

      late DiffType diffType;
      if (thisObject == null) {
        diffType = DiffType.delete;
      } else if (otherObject == null) {
        diffType = DiffType.insert;
      } else if (thisObject.sha == otherObject.sha) {
        diffType = DiffType.same;
      } else {
        File thisTempFile = File(join(tempDirectory.path, thisObject.sha))
          ..writeAsBytesSync(thisObject.fetchObject(thisCommit.branch.repository)?.blob ?? []);
        File otherTempFile = File(join(tempDirectory.path, otherObject.sha))
          ..writeAsBytesSync(otherObject.fetchObject(otherCommit.branch.repository)?.blob ?? []);

        FileDiff fileDiff = await FileDiff.calculateDiff(
          thisName: thisObject.fileName,
          thisFile: thisTempFile,
          otherName: otherObject.fileName,
          otherFile: otherTempFile,
        );
        filesDiff.add(fileDiff);
        diffType = DiffType.modify;

        thisTempFile.deleteSync(recursive: true);
        otherTempFile.deleteSync(recursive: true);
      }

      debugPrintToConsole(message: "Result: ${diffType.name}", color: CliColor.cyan);

      statistics.update(diffType, (o) => o + 1, ifAbsent: () => 1);
    }

    tempDirectory.deleteSync(recursive: true);

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

///Represents differences of 2 [File]s in memory
class FileDiff {
  File thisFile;
  String thisName;
  File otherFile;
  String otherName;

  //From this perspective
  DiffType diffType;
  Map<int, FileLineDiff> linesDiff;

  FileDiff({
    required this.thisFile,
    required this.thisName,
    required this.otherFile,
    required this.otherName,
    required this.linesDiff,
    required this.diffType,
  });

  static Future<FileDiff> calculateDiff({
    required File thisFile,
    required String thisName,
    required File otherFile,
    required String otherName,
  }) async {
    if (!thisFile.existsSync()) {
      return FileDiff(
        thisFile: thisFile,
        thisName: thisName,
        otherFile: otherFile,
        otherName: otherName,
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
            thisName: thisName,
            otherPath: otherFile.path,
            otherName: otherName,
            thisLineNo: lineNo,
            thisLine: thisTotalLines[lineNo],
            otherLine: null,
            diffType: DiffType.insert,
          ),
        );
      }

      return FileDiff(
        thisFile: thisFile,
        thisName: thisName,
        otherFile: otherFile,
        otherName: otherName,
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
        thisName: thisName,
        thisLineNo: lineNo,
        otherFile: otherFile,
        otherName: otherName,
      );
      linesDiff.putIfAbsent(lineNo, () => fileLineDiff);
    }

    return FileDiff(
      thisFile: thisFile,
      thisName: thisName,
      otherFile: otherFile,
      otherName: otherName,
      linesDiff: linesDiff,
      diffType: DiffType.modify,
    );
  }

  @override
  String toString() => """
  \n  File Comparison: (a) $thisName compare to (b) $otherName
  Lines Diff: ${linesDiff.entries.map((e) => e.value.toString()).join()}
  DiffType: $diffType
  """;
}

///Represents differences of 2 lines in a [File] in memory
class FileLineDiff {
  String thisPath;
  String thisName;
  String otherPath;
  String otherName;

  //From this perspective
  int thisLineNo;
  String? thisLine;
  String? otherLine;
  DiffType diffType;

  FileLineDiff({
    required this.thisPath,
    required this.thisName,
    required this.otherPath,
    required this.otherName,
    required this.thisLineNo,
    required this.thisLine,
    required this.otherLine,
    required this.diffType,
  });

  static Future<FileLineDiff> calculateDiff({
    required File thisFile,
    required String thisName,
    required int thisLineNo,
    Function()? onThisLineDoesntExist,
    required File otherFile,
    required String otherName,
  }) async {
    bool thisExists = thisFile.existsSync();
    bool otherExists = otherFile.existsSync();

    if (!thisExists && !otherExists) {
      return FileLineDiff(
        thisPath: thisFile.path,
        thisName: thisName,
        otherPath: otherFile.path,
        otherName: otherName,
        thisLineNo: thisLineNo,
        thisLine: null,
        otherLine: null,
        diffType: DiffType.same,
      );
    }

    List<String> thisLines = thisExists ? thisFile.readAsLinesSync() : [];
    List<String> otherLines = otherExists ? otherFile.readAsLinesSync() : [];

    if (!thisExists) {
      return FileLineDiff(
        thisPath: thisFile.path,
        thisName: thisName,
        otherPath: otherFile.path,
        otherName: otherName,
        thisLineNo: thisLineNo,
        thisLine: null,
        otherLine: otherLines[thisLineNo],
        diffType: DiffType.delete,
      );
    }

    if (!otherExists) {
      return FileLineDiff(
        thisPath: thisFile.path,
        thisName: thisName,
        otherPath: otherFile.path,
        otherName: otherName,
        thisLineNo: thisLineNo,
        thisLine: thisLines[thisLineNo],
        otherLine: null,
        diffType: DiffType.insert,
      );
    }

    if (thisLineNo > thisLines.length - 1) {
      onThisLineDoesntExist?.call();
      return FileLineDiff(
        thisPath: thisFile.path,
        thisName: thisName,
        otherPath: otherFile.path,
        otherName: otherName,
        thisLineNo: thisLineNo,
        thisLine: null,
        otherLine: otherLines[thisLineNo],
        diffType: DiffType.delete,
      );
    }
    String thisLine = thisLines[thisLineNo];

    if (thisLineNo > otherLines.length - 1) {
      return FileLineDiff(
        thisPath: thisFile.path,
        thisName: thisName,
        otherPath: otherFile.path,
        otherName: otherName,
        thisLineNo: thisLineNo,
        thisLine: thisLine,
        otherLine: null,
        diffType: DiffType.insert,
      );
    }
    String otherLine = otherLines[thisLineNo];

    // int diffScore = await levenshteinDistance(thisLine, otherLine);
    DiffType diffType = thisLine == otherLine ? DiffType.same : DiffType.modify;
    return FileLineDiff(
      thisPath: thisFile.path,
      thisName: thisName,
      otherPath: otherFile.path,
      otherName: otherName,
      thisLineNo: thisLineNo,
      thisLine: thisLine,
      otherLine: otherLine,
      diffType: diffType,
    );
  }

  @override
  String toString() => """
  \n  Line: $thisLineNo
  DiffType: $diffType
  """;
}

///Types of differences
enum DiffType { insert, modify, delete, same }

extension DiffTypeColor on DiffType {
  ///Color represented by a [DiffType]
  CliColor get color => switch (this) {
        DiffType.insert => CliColor.brightGreen,
        DiffType.modify => CliColor.brightWhite,
        DiffType.delete => CliColor.brightRed,
        DiffType.same => CliColor.yellow,
      };

  CliColor get oppositeColor => switch (this) {
        DiffType.insert => CliColor.brightRed,
        DiffType.modify => CliColor.brightYellow,
        DiffType.delete => CliColor.brightGreen,
        DiffType.same => CliColor.brightWhite,
      };

  ///Title represented by a [DiffType]
  String get title => switch (this) {
        DiffType.insert => "inserted",
        DiffType.modify => "modified",
        DiffType.delete => "deleted",
        DiffType.same => "same",
      };
}

extension CommitDiffPrint on CommitDiff {
  ///Print a [CommitDiff] from [Commit] to [FileLineDiff]
  void fullPrint() {
    printToConsole(
      message: "Commit differences",
      color: CliColor.yellow,
      style: CliStyle.underline,
      newLine: true,
    );

    printDiff();

    printToConsole(
      message: "File differences",
      color: CliColor.yellow,
      style: CliStyle.underline,
      newLine: true,
    );

    for (var a in filesDiff) {
      a.printDiff();

      //Only show differences
      for (var b in a.linesDiff.values.where((e) => e.diffType != DiffType.same)) {
        b.printDiff();
      }
    }
  }

  ///Print a [CommitDiff]
  void printDiff() {
    printToConsole(
      message: "Commits: a -> ${thisCommit.sha.hash}, b -> ${otherCommit.sha.hash}",
      color: CliColor.brightMagenta,
      style: CliStyle.bold,
      newLine: true,
    );

    printToConsole(
      message: "Files with differences: ${filesDiff.length}",
      color: CliColor.defaultColor,
    );

    printToConsole(
      message: "Statistics: ${statistic.entries.map((e) => "${e.key.color.color}${e.key.title} ${e.value}${CliColor.defaultColor.color}").join(" ")}",
      color: CliColor.blue,
    );
  }
}

extension FileDiffPrint on FileDiff {
  ///Groups and counts differences for each line in a file
  Map<DiffType, int> get diffCount {
    Map<DiffType, int> count = {};

    for (var d in linesDiff.values) {
      count.update(d.diffType, (p) => p + 1, ifAbsent: () => 1);
    }

    return count;
  }

  ///Print a [FileDiff]
  void printDiff() {
    int differences = diffCount.entries.where((e) => e.key != DiffType.same).map((e) => e.value).fold(0, (a, b) => a + b);
    String diffSummary = "${diffType.title} ($differences difference${differences == 1 ? '' : 's'})";

    printToConsole(
      message: "This File: $thisName (${basename(thisFile.path)})",
      color: CliColor.defaultColor,
      style: CliStyle.bold,
      newLine: true,
    );

    printToConsole(
      message: "Other File: $otherName (${basename(otherFile.path)})",
      color: CliColor.defaultColor,
      style: CliStyle.bold,
    );

    printToConsole(
      message: diffSummary,
      color: diffType.color,
      style: CliStyle.bold,
    );

    int insertedCount = min(diffCount[DiffType.insert] ?? 0, 20);
    int deleteCount = min(diffCount[DiffType.delete] ?? 0, 20);
    int modifiedCount = min(diffCount[DiffType.modify] ?? 0, 20);

    printToConsole(
      message:
          "${DiffType.insert.color.color}${'+' * insertedCount}inserted $insertedCount ${CliColor.defaultColor.color} ${DiffType.delete.color.color}${'-' * deleteCount}deleted $deleteCount${CliColor.defaultColor.color} ${DiffType.modify.color.color} ${"*" * modifiedCount}modified $modifiedCount${CliColor.defaultColor.color} \n",
    );
  }
}

extension FileLineDiffPrint on FileLineDiff {
  ///Print a [FileLineDiff]
  void printDiff() {
    int line = thisLineNo + 1;
    String diff = "${diffType.color.color}(${diffType.name})${CliColor.defaultColor.color}";

    printToConsole(
      message: "Line@$line $diff",
      color: CliColor.brightYellow,
      style: CliStyle.underline,
    );

    printToConsole(
      message: "This: ${thisLine ?? ""}",
      color: diffType.color,
      style: CliStyle.bold,
    );

    printToConsole(
      message: "Other: ${otherLine ?? ""}",
      color: diffType.oppositeColor,
      style: CliStyle.bold,
    );
  }
}
