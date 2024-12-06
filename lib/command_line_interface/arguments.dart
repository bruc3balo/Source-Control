
///Cli commands run by the user
enum CliCommandsEnum {
  help(
    command: "help",
    options: [],
    description: "Print usage information",
  ),
  init(
    command: "init",
    description: "Initialized a new repository",
    options: [
      CommandOption(
        optionEnum: CliCommandOptionsEnum.path,
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
        optionEnum: CliCommandOptionsEnum.filePattern,
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
        optionEnum: CliCommandOptionsEnum.add,
        mandatory: false,
      ),
      CommandOption(
        optionEnum: CliCommandOptionsEnum.remove,
        mandatory: false,
      ),
    ],
  ),
  log(
    command: "log",
    description: "Shows commit history for a specific branch",
    options: [
      CommandOption(
        optionEnum: CliCommandOptionsEnum.branch,
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
        optionEnum: CliCommandOptionsEnum.branch,
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
        optionEnum: CliCommandOptionsEnum.message,
        mandatory: true,
      ),
    ],
  ),
  diff(
    command: "diff",
    description: "Show differences between 2 commits",
    options: [
      CommandOption(
        optionEnum: CliCommandOptionsEnum.thisBranch,
        mandatory: false,
      ),
      CommandOption(
        optionEnum: CliCommandOptionsEnum.thisSha,
        mandatory: false,
      ),
      CommandOption(
        optionEnum: CliCommandOptionsEnum.otherBranch,
        mandatory: true,
      ),
      CommandOption(
        optionEnum: CliCommandOptionsEnum.otherSha,
        mandatory: false,
      ),
    ],
  ),
  merge(
    command: "merge",
    description: "Merge a commit from another branch to the current branch",
    options: [
      CommandOption(
        optionEnum: CliCommandOptionsEnum.branch,
        mandatory: true,
        defaultValue: null,
      )
    ],
  );

  final String command;
  final String description;
  final List<CommandOption> options;

  const CliCommandsEnum({
    required this.command,
    required this.description,
    required this.options,
  });

  static Map<String, CliCommandsEnum> cliCommandsMap = {
    for (var c in CliCommandsEnum.values) c.command: c,
  };
}

///Cli options and flags attached to [CliCommandsEnum]
enum CliCommandOptionsEnum {

  add(
    option: "add",
    abbreviation: "a",
    aliases: [],
    description: "Adds an entry",
    valueHelp: "value of entry"
  ),
  remove(
    option: "remove",
    abbreviation: "r",
    aliases: ["rm"],
    description: "Removes an entry",
    valueHelp: "value of entry"
  ),
  branch(
    option: "branch",
    abbreviation: "b",
    aliases: [],
    description: "Refers to a specific branch",
    valueHelp: "name of branch"
  ),
  message(
    option: "message",
    abbreviation: "m",
    aliases: [],
    description: "Adds a message",
    valueHelp: "message"
  ),
  path(
    option: "path",
    abbreviation: "p",
    aliases: [],
    description: "Describes path to execute command",
    valueHelp: "path"
  ),
  filePattern(
    option: "file",
    abbreviation: "f",
    aliases: [],
    description: "Describes the file pattern to search for",
    valueHelp: "regex pattern"
  ),
  thisBranch(
    option: "this-branch",
    abbreviation: "t",
    aliases: ["branch-a"],
    description: "Selects this branch name",
    valueHelp: "branch name",
  ),
  otherBranch(
    option: "other-branch",
    abbreviation: "o",
    aliases: ["branch-b"],
    description: "Selects other branch name",
    valueHelp: "branch name",
  ),
  thisSha(
    option: "this-sha",
    abbreviation: 'x',
    aliases: ["sha-a"],
    description: "Selects this commit sha",
    valueHelp: "commit sha",
  ),
  otherSha(
    option: "other-sha",
    abbreviation: "y",
    aliases: ["sha-b"],
    description: "Selects other commit sha",
    valueHelp: "commit sha"
  ),
  help(
    option: "help",
    abbreviation: "h",
    aliases: [],
    description: "Print usage information",
    valueHelp: null
  ),
  verbose(
    option: "verbose",
    abbreviation: "v",
    aliases: [],
    description: "Prints debug statements",
    valueHelp: null
  );

  final String option;
  final String abbreviation;
  final List<String> aliases;
  final String description;
  final String? valueHelp;

  const CliCommandOptionsEnum({
    required this.option,
    required this.abbreviation,
    required this.aliases,
    required this.description,
    required this.valueHelp,
  });

  static Map<String, CliCommandOptionsEnum> cliCommandOptionsMap = {
    for (var c in CliCommandOptionsEnum.values) c.option: c,
  };
}

///Configuration of a [CliCommandOptionsEnum] with respect
///to each [CliCommandsEnum]
class CommandOption<T> {
  final CliCommandOptionsEnum optionEnum;
  final bool mandatory;
  final T? defaultValue;

  const CommandOption({
    required this.optionEnum,
    required this.mandatory,
    this.defaultValue,
  });
}
