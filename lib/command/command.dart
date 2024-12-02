import 'package:balo/command/command_mapper.dart';
import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/branch.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/state.dart';

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

///Command to initialize a repository
class InitializeRepositoryCommand implements Command {
  final Repository repository;

  const InitializeRepositoryCommand({required this.repository});

  @override
  Future<void> execute() async {
    await repository.initializeRepository(
      onAlreadyInitialized: () => printToConsole(
        message: "Balo repository is already initialized",
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
  final State state;

  CreateStateFileCommand(this.state);

  @override
  Future<void> execute() async {
    await state.createStateFile();
  }

  @override
  Future<void> undo() async {
    await state.deleteStateFile();
  }
}

///Command to create an ignore file
class CreateIgnoreFileCommand implements Command {
  final Ignore ignore;

  CreateIgnoreFileCommand(this.ignore);

  @override
  Future<void> execute() async {
    await ignore.createIgnoreFile();
  }

  @override
  Future<void> undo() async {
    await ignore.deleteIgnoreFile();
  }
}

///Command to create a branch
class CreateNewBranchCommand implements Command {
  final Branch branch;

  CreateNewBranchCommand(this.branch);

  @override
  Future<void> execute() async {
    await branch.createBranch();
  }

  @override
  Future<void> undo() async {
    await branch.deleteBranch();
  }
}
