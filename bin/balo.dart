import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/command_line_interface/cli.dart';


Future<void> main(List<String> arguments) async {
  final CommandLineRunner runner = CommandLineRunner();

  printToConsole("Arguments: $arguments \n");

  //Interface to run commands
  List<Command> commandSeries = runner.inputToCommands(arguments);
  int code = await runner.runCommand(commandSeries);

  printToConsole("Finished with exit code: $code");

  exit(code);
}
