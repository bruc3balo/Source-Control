// Command interface

import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/branch.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/repository.dart';

abstract class Command {
  Future<void> execute();

  Future<void> undo();
}

abstract class CommandCreator {
  List<Command> inputToCommands(String input);

  Future<void> runCommand(List<Command> commands);
}

///Parses user input and creates commands
///Runs commands created
class CommandLineRunner implements CommandCreator {

  @override
  List<Command> inputToCommands(String input) {
    List<Command> commandsToRun = [];
    return commandsToRun;
  }

  @override
  Future<void> runCommand(List<Command> commands) async {
    int i = 0;
    try {
      while (i < commands.length) {
        await commands[i++].execute();
      }
    } catch (e) {
      while (i > 0) {
        await commands[i--].undo();
      }
    }
  }

}

///Commands
///Command to initialize a repository
class InitializeRepositoryCommand implements Command {
  final Repository repository;

  const InitializeRepositoryCommand({required this.repository});

  @override
  Future<void> execute() async {
    await repository.initializeRepository(
      onAlreadyInitialized: () => printToConsole(
        "Balo repository is already initialized",
      ),
    );
  }

  @override
  Future<void> undo() async {
    await repository.unInitializeRepository(
      onNotInitialized: () => printToConsole(
        "Balo repository is not initialized",
      ),
    );
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
class CreateBranchCommand implements Command {
  final Branch branch;

  CreateBranchCommand(this.branch);

  @override
  Future<void> execute() async {
    await branch.createBranch();
  }

  @override
  Future<void> undo() async {
    await branch.deleteBranch();
  }
}
