import 'package:balo/command_line_interface/cli.dart';

enum CommandMapperEnum {
  help(
    command: ["help", "-h"],
    description: "Print usage information",
    options: [CommandOptionsMapperEnum.path],
  ),
  init(
    command: ["init"],
    description: "Initialized a new repository",
    options: [CommandOptionsMapperEnum.path],
  ),
  add(
    command: ["add"],
    description: "Stage files for commit",
    options: [CommandOptionsMapperEnum.pattern],
  ),
  ignore(
    command: ["ignore"],
    description: "Modify ignore file",
    options: [CommandOptionsMapperEnum.add, CommandOptionsMapperEnum.remove],
  ),
  log(
    command: ["log"],
    description: "Shows commit history for a specific branch",
    options: [CommandOptionsMapperEnum.branch],
  ),
  status(
    command: ["status"],
    description: "Get status of stage",
    options: [],
  ),
  branch(
    command: ["branch"],
    description: "Get branch info ",
    options: [],
  ),
  checkout(
    command: ["checkout"],
    description: "Switch branches",
    options: [CommandOptionsMapperEnum.branch],
  ),
  commit(
    command: ["commit"],
    description: "Commit staged files",
    options: [CommandOptionsMapperEnum.message],
  ),
  diff(
    command: ["diff"],
    description: "Show differences between 2 commits",
    options: [CommandOptionsMapperEnum.branchA, CommandOptionsMapperEnum.shaA, CommandOptionsMapperEnum.branchB, CommandOptionsMapperEnum.shaB],
  );

  final List<String> command;
  final String description;
  final List<CommandOptionsMapperEnum> options;

  const CommandMapperEnum({
    required this.command,
    required this.description,
    required this.options,
  });

  static final Map<String, CommandMapperEnum> commandOptionsMap = {
    for (var e in CommandMapperEnum.values)
      for (var a in e.command) a.toLowerCase().trim(): e
  };
}

enum CommandOptionsMapperEnum {
  add(
    option: ["--add"],
    description: "Adds an entry",
  ),
  remove(
    option: ["--remove", "rm"],
    description: "Removes an entry",
  ),
  branch(
    option: ["-b"],
    description: "Refers to a specific branch",
  ),
  message(
    option: ["-m", "--message"],
    description: "Adds a message to a commit",
  ),
  path(
    option: ["-p", "--path"],
    description: "Describes path to execute command",
  ),
  pattern(
    option: ["-f", "--file"],
    description: "Describes the file pattern to search for",
  ),
  branchA(
    option: ["--b-a"],
    description: "Selects branch a name",
  ),
  shaA(
    option: ["--sha-a"],
    description: "Selects commit b sha",
  ),
  verbose(
    option: ["--v"],
    description: "Prints debug statements",
  ),
  shaB(
    option: ["--sha-b"],
    description: "Selects commit a sha",
  ),
  branchB(
    option: ["--b-b"],
    description: "Selects branch b name",
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
          "   Options: \n   ${c.options.map((o) => "${o.option.join(", ")}   ${o.description}").join("\n   ")}",
      color: CliColor.defaultColor,
    );
  }
}
