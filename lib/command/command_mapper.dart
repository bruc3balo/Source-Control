import 'package:balo/command/command.dart';
import 'package:balo/command_line_interface/cli.dart';

enum CommandMapperEnum {
  help(
    command: ["--help", "-h"],
    description: "Print usage information",
    type: InitializeRepositoryCommand,
    options: [CommandOptionsMapperEnum.path],
  ),
  init(
    command: ["init"],
    description: "Initialized a new repository",
    type: InitializeRepositoryCommand,
    options: [CommandOptionsMapperEnum.path],
  );

  final List<String> command;
  final String description;
  final Type type;
  final List<CommandOptionsMapperEnum> options;

  const CommandMapperEnum({
    required this.command,
    required this.description,
    required this.type,
    required this.options,
  });

  static final Map<String, CommandMapperEnum> commandOptionsMap = {
    for (var e in CommandMapperEnum.values)
      for (var a in e.command) a.toLowerCase().trim(): e
  };
}

enum CommandOptionsMapperEnum {
  path(
    option: ["-p", "--path"],
    description: "Describes path to execute command",
  );

  final List<String> option;
  final String description;

  const CommandOptionsMapperEnum({
    required this.option,
    required this.description,
  });

  static final Map<String, CommandOptionsMapperEnum> commandOptionsMap = {
    for (var e in CommandOptionsMapperEnum.values)
      for (var a in e.option) a.toLowerCase().trim(): e
  };
}

void printHelp() {
  //Intro
  printToConsole(
    message: "A cli utility for balo repository \n",
    color: CliColor.defaultColor,
  );

  //Usage
  printToConsole(message: "Usage:", color: CliColor.blue);
  printToConsole(message: "balo \$command \$option \$arguments \n");

  //Example
  printToConsole(message: "Example:", color: CliColor.blue);
  printToConsole(message: "balo init .");

  //Commands
  printToConsole(message: "Commands:", color: CliColor.blue, newLine: true);
  for (var c in CommandMapperEnum.values) {
    printToConsole(
      message: "   ${c.command.join(", ")}   ${c.description}",
      color: CliColor.yellow,
      newLine: true,
    );
    printToConsole(
      message:
          "   Options: ${c.options.map((o) => "${o.option.join(", ")}   ${o.description}").join("\n")}",
      color: CliColor.defaultColor,
    );
  }
}
