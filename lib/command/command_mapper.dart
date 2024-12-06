import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';

enum CommandMapperEnum {
  help(
    command: "help",
    description: "Print usage information",
    options: [],
  ),
  init(
    command: "init",
    description: "Initialized a new repository",
    options: [
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.path,
        mandatory: false,
        defaultValue: ".",
      ),
    ],
  ),
  add(
    command: "add",
    description: "Stage files for commit",
    options: [
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.pattern,
        mandatory: false,
        defaultValue: ".",
      ),
    ],
  ),
  ignore(
    command: "ignore",
    description: "Modify ignore file",
    options: [
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.add,
        mandatory: false,
      ),
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.remove,
        mandatory: false,
      ),
    ],
  ),
  log(
    command: "log",
    description: "Shows commit history for a specific branch",
    options: [
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.branch,
        mandatory: false,
      ),
    ],
  ),
  status(
    command: "status",
    description: "Get status of branch",
    options: [],
  ),
  branch(
    command: "branch",
    description: "Get branch info ",
    options: [],
  ),
  checkout(
    command: "checkout",
    description: "Switch branches",
    options: [
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.branch,
        mandatory: true,
        defaultValue: null,
      )
    ],
  ),
  commit(
    command: "commit",
    description: "Commit staged files",
    options: [
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.message,
        mandatory: true,
      ),
    ],
  ),
  diff(
    command: "diff",
    description: "Show differences between 2 commits",
    options: [
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.branchA,
        mandatory: true,
      ),
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.shaA,
        mandatory: true,
      ),
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.branchB,
        mandatory: true,
      ),
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.shaB,
        mandatory: true,
      ),
    ],
  ),
  merge(
    command: "merge",
    description: "Merge a commit from another branch to the current branch",
    options: [
      CommandOption(
        optionEnum: CommandOptionsMapperEnum.branch,
        mandatory: true,
        defaultValue: null,
      )
    ],
  );

  final String command;
  final String description;

  //Mandatory bool
  final List<CommandOption> options;

  const CommandMapperEnum({
    required this.command,
    required this.description,
    required this.options,
  });

  static final Map<String, CommandMapperEnum> commandOptionsMap = {
    for (var e in CommandMapperEnum.values) e.command.toLowerCase().trim(): e
  };
}

enum CommandOptionsMapperEnum {
  add(
    option: ["--add"],
    description: "Adds an entry",
  ),
  remove(
    option: ["--remove", "-rm"],
    description: "Removes an entry",
  ),
  branch(
    option: ["--branch", "-b"],
    description: "Refers to a specific branch",
  ),
  message(
    option: ["--message", "-m"],
    description: "Adds a message to a commit",
  ),
  path(
    option: ["--path", "-p"],
    description: "Describes path to execute command",
  ),
  pattern(
    option: ["--file", "-f"],
    description: "Describes the file pattern to search for",
  ),
  branchA(
    option: ["--branch-a", "-ba"],
    description: "Selects branch a name",
  ),
  branchB(
    option: ["--branch-b", "-bb"],
    description: "Selects branch b name",
  ),
  shaA(
    option: ["--sha-a"],
    description: "Selects commit b sha",
  ),
  shaB(
    option: ["--sha-b"],
    description: "Selects commit a sha",
  ),
  verbose(
    option: ["--v"],
    description: "Prints debug statements",
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

class CommandOption {
  final CommandOptionsMapperEnum optionEnum;
  final bool mandatory;
  final String? defaultValue;

  const CommandOption({
    required this.optionEnum,
    required this.mandatory,
    this.defaultValue,
  });
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
  printToConsole(message: "Example:", color: CliColor.blue, newLine: true);
  printToConsole(message: "balo init .");

  print('Available commands:');
  for (CommandMapperEnum command in CommandMapperEnum.values) {
    printToConsole(
      message: '- ${command.command}: ${command.description}',
      color: CliColor.defaultColor,
    );

    printToConsole(message: '  Options:');
    for (CommandOption option in command.options) {
      printToConsole(
        message:
            '    ${option.optionEnum.option.join(", ")}: ${option.optionEnum.description}',
        color: CliColor.defaultColor,
      );
    }
  }
}
