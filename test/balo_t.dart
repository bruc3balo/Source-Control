import 'dart:io';

import 'package:balo/command/command_facade.dart';
import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/command_line_interface/cli_execution.dart';
import 'package:balo/command_line_interface/input_parser.dart';
import 'package:balo/command_line_interface/user_input.dart';
import 'package:balo/repository/repository.dart';

Future<int> runTest(List<String> arguments) async {
  UserInput userInput = CliUserInput(arguments);
  final UndoableCommandExecutor runner = DefaultCommandLineRunner();

  //Interface to run commands
  CommandFacade commandFacade = runner.inputToCommands(
    userInput,
    inputParser,
  );
  return await runner.runCommand(commandFacade.initialize());
}

///Creates a [Repository] and runs a [testWithRepository] function then finally the [Repository]
Future<void> testWithRepository({
  required Future<void> Function(Repository) testWithRepository,
}) async {
  Repository tempRepository = Repository(Directory.current.path);

  try {
    //Run create repository command
    int code = await runTest([
      CliCommandsEnum.init.command,
      "-${CliCommandOptionsEnum.path.abbreviation}",
      tempRepository.path,
      "-${CliCommandOptionsEnum.verbose.abbreviation}"
    ]);
    assert(code == 0);

    //Check if repository was created
    bool repositoryFound = Directory(tempRepository.repositoryPath).existsSync();
    assert(repositoryFound);

    await testWithRepository(tempRepository);
  } catch (e, trace) {
    rethrow;
  } finally {
    //Clean up repository
    tempRepository.unInitializeRepository();
    bool repositoryDeleted = !Directory(tempRepository.repositoryPath).existsSync();
    assert(repositoryDeleted);
  }
}
