import 'package:balo/command/command_mapper.dart';
import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/variables.dart';
import 'package:dart_console/dart_console.dart';

abstract class Command {
  Future<void> execute();

  Future<void> undo();
}

///Command to show help
class ShowHelpCommand implements Command {
  @override
  Future<void> execute() async {
    printHelp();
  }

  @override
  Future<void> undo() async {}
}

///Command to show help
class ShowErrorCommand implements Command {
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
class InitializeRepositoryCommand implements Command {
  final Repository repository;

  const InitializeRepositoryCommand(this.repository);

  @override
  Future<void> execute() async {
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
    await repository.unInitializeRepository(
      onRepositoryNotInitialized: () => printToConsole(
        message: "Balo repository is not initialized",
      ),
    );
  }
}

///Command to create state file
class CreateStateFileCommand implements Command {
  final Repository repository;
  final String currentBranch;

  CreateStateFileCommand(this.repository, this.currentBranch);

  @override
  Future<void> execute() async {
    await repository.state.createStateFile(
      currentBranch: currentBranch,
    );
  }

  @override
  Future<void> undo() async {
    await repository.state.deleteStateFile();
  }
}

///Command to create an ignore file
class CreateIgnoreFileCommand implements Command {
  final Repository repository;

  CreateIgnoreFileCommand(this.repository);

  @override
  Future<void> execute() async {
    await repository.ignore.createIgnoreFile();
  }

  @override
  Future<void> undo() async {
    await repository.ignore.deleteIgnoreFile();
  }
}

///Command to create a branch
class CreateNewBranchCommand implements Command {
  final Repository repository;
  final String name;
  late final Branch branch = Branch(name, repository);

  CreateNewBranchCommand(this.repository, this.name);

  @override
  Future<void> execute() async {
    await branch.createBranch();
    await branch.createManagerFile();
  }

  @override
  Future<void> undo() async {
    await branch.deleteBranch();
  }
}

///Command to stage files
class StageFilesCommand implements Command {
  final Staging staging;
  final String pattern;

  StageFilesCommand(this.staging, this.pattern);

  @override
  Future<void> execute() async {
    staging.stageFiles(pattern: pattern);
  }

  @override
  Future<void> undo() async {
    staging.unstageFiles();
  }
}

///Command to add ignore pattern
class AddIgnorePatternCommand implements Command {
  final Repository repository;
  final String pattern;

  AddIgnorePatternCommand(this.repository, this.pattern);

  @override
  Future<void> execute() async {
    repository.ignore.addIgnore(pattern: pattern);
  }

  @override
  Future<void> undo() async {
    repository.ignore.removeIgnore(pattern: pattern);
  }
}

///Command to remove ignore pattern
class RemoveIgnorePatternCommand implements Command {
  final Repository repository;
  final String pattern;

  RemoveIgnorePatternCommand(this.repository, this.pattern);

  @override
  Future<void> execute() async {
    repository.ignore.removeIgnore(pattern: pattern);
  }

  @override
  Future<void> undo() async {
    repository.ignore.addIgnore(pattern: pattern);
  }
}

///Command to print the current branch
class PrintCurrentBranchCommand implements Command {
  final Repository repository;

  PrintCurrentBranchCommand(this.repository);

  @override
  Future<void> execute() async {
    Branch? branch = await repository.state.getCurrentBranch(
      onRepositoryNotInitialized: () =>
          printToConsole(message: "Repository not initialized"),
    );

    if (branch == null) return;

    printToConsole(
      message: "${branch.branchName}*",
      style: CliStyle.bold,
      alignment: TextAlignment.left,
      color: CliColor.brightCyan,
    );
  }

  @override
  Future<void> undo() async {}
}

///Command to get status of current branch
class GetStatusOfCurrentBranch implements Command {
  final Repository repository;

  GetStatusOfCurrentBranch(this.repository);

  @override
  Future<void> execute() async {
    StateData? stateData = repository.state.stateInfo;
    if(stateData == null) {
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
  Future<void> undo() async {}

}

///Command to commit staged files
class CommitStagedFilesCommand implements Command {
  final Repository repository;
  final String message;

  CommitStagedFilesCommand(this.repository, this.message);

  @override
  Future<void> execute() async {
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
    await staging.commitStagedFiles(message: message);
  }

  @override
  Future<void> undo() async {}
}

///Command to get branch commits
class GetBranchCommitHistory implements Command {
  final Repository repository;
  final String branchName;

  GetBranchCommitHistory(this.repository, this.branchName);

  @override
  Future<void> execute() async {
    Branch branch = Branch(branchName, repository);
    BranchMetaData? metaData = branch.branchMetaData;
    if(metaData == null) {
      printToConsole(message: "Branch out of sync", color: CliColor.brightRed);
      return;
    }

    String history = metaData.commits.values
        .map((c) => "Commit: ${c.sha} \nMessage: ${c.message} \nDate: ${c.commitedAt.toLocal().toIso8601String()}")
        .join("\n");

    printToConsole(
      message: history,
      color: CliColor.cyan
    );
  }

  @override
  Future<void> undo() async {}
}
