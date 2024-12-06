import 'dart:isolate';

import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/command_line_interface/input_parser.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/diff/diff.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:dart_console/dart_console.dart';

abstract class UndoableCommand {
  Future<void> execute();

  Future<void> undo();
}

///Command to show help
class ShowHelpCommand extends UndoableCommand {
  final CliCommandsEnum? command;

  ShowHelpCommand({this.command});

  @override
  Future<void> execute() async {
    inputParser.printHelp(command: command);
  }

  @override
  Future<void> undo() async {}
}

///Command to show help
class ShowErrorCommand extends UndoableCommand {
  final String error;

  ShowErrorCommand(this.error);

  @override
  Future<void> execute() async {
    printToConsole(
      message: error,
      color: CliColor.red,
      newLine: true,
      alignment: TextAlignment.center,
      style: CliStyle.bold,
    );
  }

  @override
  Future<void> undo() async {}
}

///Command to initialize a repository
class InitializeRepositoryCommand extends UndoableCommand {
  final Repository repository;

  InitializeRepositoryCommand(this.repository);

  @override
  Future<void> execute() async {
    debugPrintToConsole(
      message: "Executing initialize repository command",
    );
    await repository.initializeRepository(
      onAlreadyInitialized: () => printToConsole(
        message: "Balo repository is already initialized",
      ),
      onSuccessfullyInitialized: () => printToConsole(
        message: "Repository initialized",
      ),
    );
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(
      message: "Undoing initialize repository command",
    );

    await repository.unInitializeRepository(
      onRepositoryNotInitialized: () => printToConsole(
        message: "Balo repository is not initialized",
      ),
    );
  }
}

///Command to create state file
class CreateStateFileCommand extends UndoableCommand {
  final Repository repository;
  final Branch currentBranch;

  CreateStateFileCommand(this.repository, this.currentBranch);

  @override
  Future<void> execute() async {
    debugPrintToConsole(
      message: "Executing create state file command",
    );
    await repository.state.createStateFile(
      currentBranch: currentBranch,
    );
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(
      message: "Undoing create state file command",
    );
    await repository.state.deleteStateFile();
  }
}

///Command to create an ignore file
class CreateIgnoreFileCommand extends UndoableCommand {
  final Repository repository;

  CreateIgnoreFileCommand(this.repository);

  @override
  Future<void> execute() async {
    debugPrintToConsole(
      message: "Executing ignore file command",
    );
    await repository.ignore.createIgnoreFile();
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(
      message: "Undoing ignore file command",
    );
    await repository.ignore.deleteIgnoreFile();
  }
}

///Command to create a branch
class CreateNewBranchCommand extends UndoableCommand {
  final Repository repository;
  final Branch branch;

  CreateNewBranchCommand(this.repository, this.branch);

  @override
  Future<void> execute() async {
    debugPrintToConsole(
      message: "Executing create new branch command",
    );
    await branch.createBranch();
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(
      message: "Undoing create new branch command",
    );
    await branch.deleteBranch();
  }
}

///Command to stage files
class StageFilesCommand extends UndoableCommand {
  final Staging staging;
  final String pattern;

  StageFilesCommand(this.staging, this.pattern);

  @override
  Future<void> execute() async {
    debugPrintToConsole(
      message: "Executing stage files command",
    );
    await Isolate.run(
      () async => await staging.stageFiles(
        pattern: pattern,
        onFileSystemException: (e) => debugPrintToConsole(
          message: e.message,
          color: CliColor.red,
        ),
        onUninitializedRepository: () => debugPrintToConsole(
          message: "Repository not initialized",
        ),
      ),
    );
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(
      message: "Undoing stage files command",
    );
    staging.unstageFiles();
  }
}

///Command to add ignore pattern
class AddIgnorePatternCommand extends UndoableCommand {
  final Repository repository;
  final String pattern;

  AddIgnorePatternCommand(this.repository, this.pattern);

  @override
  Future<void> execute() async {
    debugPrintToConsole(
      message: "Executing add ignore pattern command",
    );
    repository.ignore.addIgnore(pattern: pattern);
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(
      message: "Undoing add ignore pattern command",
    );
    repository.ignore.removeIgnore(pattern: pattern);
  }
}

///Command to remove ignore pattern
class RemoveIgnorePatternCommand extends UndoableCommand {
  final Repository repository;
  final String pattern;

  RemoveIgnorePatternCommand(this.repository, this.pattern);

  @override
  Future<void> execute() async {
    debugPrintToConsole(
      message: "Executing remove ignore pattern command",
    );
    repository.ignore.removeIgnore(pattern: pattern);
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(
      message: "Undoing remove ignore pattern command",
    );
    repository.ignore.addIgnore(pattern: pattern);
  }
}

///Command to print the current branch
class ListBranchesCommand extends UndoableCommand {
  final Repository repository;

  ListBranchesCommand(this.repository);

  @override
  Future<void> execute() async {
    Branch? currentBranch = repository.state.getCurrentBranch(
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository not initialized",
        color: CliColor.red,
      ),
      onNoStateFile: () => debugPrintToConsole(
        message: "No state file found",
      ),
    );

    for (Branch b in repository.allBranches) {
      bool isCurrentBranch = b.branchName == currentBranch?.branchName;
      printToConsole(
        message: "${b.branchName} ${isCurrentBranch ? "*" : ''}",
        style: isCurrentBranch ? null : CliStyle.bold,
        alignment: TextAlignment.left,
        color: isCurrentBranch ? CliColor.brightCyan : CliColor.white,
      );
    }
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(
      message: "Undoing get status of current branch command",
    );
  }
}

///Command to get status of current branch
class GetStatusOfCurrentBranch extends UndoableCommand {
  final Repository repository;

  GetStatusOfCurrentBranch(this.repository);

  @override
  Future<void> execute() async {
    debugPrintToConsole(message: "Executing get status of current branch command");

    StateData? stateData = repository.state.stateInfo;
    if (stateData == null) {
      printToConsole(
        message: "Unable to get branch info",
        style: CliStyle.bold,
        alignment: TextAlignment.left,
        color: CliColor.red,
      );
      return;
    }

    Branch branch = Branch(stateData.currentBranch, repository);

    List<String> paths = branch.staging.stagingData?.filesToBeStaged ?? [];
    printToConsole(
      message: paths.join("\n"),
      style: CliStyle.bold,
      alignment: TextAlignment.left,
      color: CliColor.brightGreen,
    );
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(message: "Undoing get status of current branch command");
  }
}

///Command to commit staged files
class CommitStagedFilesCommand extends UndoableCommand {
  final Repository repository;
  final String message;

  CommitStagedFilesCommand(this.repository, this.message);

  @override
  Future<void> execute() async {
    debugPrintToConsole(message: "Executing commit staged files command");

    Branch? branch = repository.state.getCurrentBranch();
    if (branch == null) {
      printToConsole(
        message: "Failed to get current branch",
        style: CliStyle.bold,
        alignment: TextAlignment.left,
        color: CliColor.red,
      );
      return;
    }

    late final Staging staging = Staging(branch);
    if (!staging.isStaged) {
      printToConsole(
        message: "Files not staged",
        style: CliStyle.bold,
        alignment: TextAlignment.left,
        color: CliColor.red,
      );
      return;
    }
    await Isolate.run(() async {
      await staging.commitStagedFiles(message: message);
    });
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(message: "Undoing commiting files command");
  }
}

///Command to get branch commits
class GetBranchCommitHistoryCommand extends UndoableCommand {
  final Repository repository;
  final String branchName;

  GetBranchCommitHistoryCommand(this.repository, this.branchName);

  @override
  Future<void> execute() async {
    debugPrintToConsole(message: "Executing get branch history command on $branchName");

    Branch branch = Branch(branchName, repository);
    BranchMetaData? metaData = branch.branchMetaData;
    if (metaData == null) {
      printToConsole(message: "Branch out of sync", color: CliColor.brightRed);
      return;
    }

    String history =
        metaData.commits.values.map((c) => "Commit: ${c.sha} \nMessage: ${c.message} \nDate: ${c.commitedAt.toLocal().toIso8601String()}").join("\n");

    printToConsole(message: history, color: CliColor.cyan);
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(
      message: "Undoing get branch history command on $branchName",
    );
  }
}

///Command to checkout to branch
class CheckoutToBranchCommand extends UndoableCommand {
  final Repository repository;
  final Branch branch;

  CheckoutToBranchCommand(this.repository, this.branch);

  @override
  Future<void> execute() async {
    debugPrintToConsole(message: "Executing checkout to branch command");
    await Isolate.run(() async {
      await branch.checkoutToBranch(
        onRepositoryNotInitialized: () => debugPrintToConsole(message: "Repository not initialized"),
        onSameBranch: () => debugPrintToConsole(message: "Cannot checkout to same branch"),
        onStateDoesntExists: () => debugPrintToConsole(message: "State doesn't exist"),
        onBranchMetaDataDoesntExists: () => debugPrintToConsole(message: "Branch meta data doesn't exists"),
        onFileSystemException: (e) => debugPrintToConsole(message: e.message, color: CliColor.red),
      );
    });
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(message: "Undoing checkout to branch command");
  }
}

///Command to diff between 2 commits
class ShowCommitDiffCommand extends UndoableCommand {
  final Repository repository;
  final Commit thisCommit;
  final Commit otherCommit;

  ShowCommitDiffCommand(this.repository, this.thisCommit, this.otherCommit);

  @override
  Future<void> execute() async {
    debugPrintToConsole(message: "Executing compare commit diff command");
    await Isolate.run(() async {
      await thisCommit.compareCommitDiff(
        other: otherCommit,
        onDiffCalculated: (d) => d.fullPrint(),
        onNoOtherCommitMetaData: () => debugPrintToConsole(message: "Commit b ${otherCommit.sha} (${otherCommit.branch.branchName}) has no commit meta data"),
        onNoOtherCommitBranchMetaData: () => debugPrintToConsole(message: "Commit b ${otherCommit.sha} (${otherCommit.branch.branchName}) has no branch data"),
        onNoThisCommitMetaData: () => debugPrintToConsole(message: "Commit a ${thisCommit.sha} (${thisCommit.branch.branchName}) has no commit meta data"),
        onNoThisCommitBranchMetaData: () => debugPrintToConsole(message: "Commit a ${thisCommit.sha} (${thisCommit.branch.branchName}) has no branch data"),
      );
    });
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(message: "Undoing checkout to branch command");
  }
}

///Command to merge a branch with a working dir
class MergeBranchCommand extends UndoableCommand {
  final Repository repository;
  final Branch thisBranch;
  final Branch otherBranch;

  MergeBranchCommand(this.repository, this.thisBranch, this.otherBranch);

  @override
  Future<void> execute() async {
    debugPrintToConsole(message: "Executing merge branch command");

    await thisBranch.mergeFromOtherBranchIntoThis(
      otherBranch: otherBranch,
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository not initialized",
      ),
      onNoOtherBranchMetaData: () => debugPrintToConsole(
        message: "${otherBranch.branchName} branch doesn't exist",
      ),
      onNoCommit: () => debugPrintToConsole(
        message: "${otherBranch.branchName} branch doesn't have a commit",
      ),
    );
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(message: "Undoing merge branch command");
  }
}
