import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/command_line_interface/cli.dart';

Future<void> main(List<String> arguments) async {
  final CommandLineRunner runner = CommandLineRunner();

  printToConsole(
    message: "Arguments: $arguments \n",
    color: CliColor.brightMagenta,
    style: CliStyle.bold,
    newLine: true,
  );

  //Interface to run commands
  List<Command> commandSeries = runner.inputToCommands(arguments);
  int code = await runner.runCommand(commandSeries);

  printToConsole(
    message: "Finished with exit code: $code",
    color: CliColor.brightYellow,
    style: CliStyle.bold,
    newLine: true,
  );

  exit(code);
}
