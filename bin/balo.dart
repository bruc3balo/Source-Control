import 'dart:io';
import 'dart:isolate';

import 'package:balo/command/command_facade.dart';
import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/user_input/user_input.dart';

Future<void> main(List<String> arguments) async {
  UserInput userInput = UserInput(arguments);
  final CommandLineRunner runner = CommandLineRunner();

  debugPrintToConsole(
    message: "Arguments: ${userInput.toString()} \n",
    style: CliStyle.bold,
    newLine: true,
  );

  //Interface to run commands
  CommandFacade commandFacade = runner.inputToCommands(userInput);
  int code = await runner.runCommand(commandFacade.initialize());

  printToConsole(
    message: "Finished with exit code: $code",
    color: CliColor.brightYellow,
    style: CliStyle.bold,
    newLine: true,
  );

  exit(code);
}
