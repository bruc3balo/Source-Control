import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/branch.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/state.dart';

abstract class Command {
  Future<void> execute();

  Future<void> undo();
}

abstract class CommandCreator {
  List<Command> inputToCommands(List<String> input);

  //Run commands and return and exit code
  Future<int> runCommand(List<Command> commands);
}

///Parses user input and creates commands
///Runs commands created
class CommandLineRunner implements CommandCreator {
  @override
  List<Command> inputToCommands(List<String> input) {
    List<Command> commandsToRun = [];
    return commandsToRun;
  }

  @override
  Future<int> runCommand(List<Command> commands) async {
    int i = 0;
    try {
      while (i < commands.length) {
        await commands[i++].execute();
      }
      return 0;
    } catch (e) {
      while (i > 0) {
        await commands[i--].undo();
      }
      return 1;
    }
  }
}

//Commands

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
      onRepositoryNotInitialized: () => printToConsole(
        "Balo repository is not initialized",
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
