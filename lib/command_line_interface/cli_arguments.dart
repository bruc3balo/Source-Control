
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
    aliases: ["append"],
    description: "Add an entry to the configuration or file",
    valueHelp: "entry_value",
  ),
  remove(
    option: "remove",
    abbreviation: "r",
    aliases: ["delete, rm"],
    description: "Remove an entry from the configuration",
    valueHelp: "entry_value",
  ),
  branch(
    option: "branch",
    abbreviation: "b",
    aliases: ["br", "branch-name"],
    description: "Specify a branch to operate on",
    valueHelp: "branch_name",
  ),
  message(
    option: "message",
    abbreviation: "m",
    aliases: ["msg"],
    description: "Provide a commit or operation message",
    valueHelp: '"commit_message"'
  ),
  path(
    option: "path",
    abbreviation: "p",
    aliases: ["dir, directory"],
    description: "Specify the file path for the operation",
    valueHelp: "file_path"
  ),
  filePattern(
    option: "file",
    abbreviation: "f",
    aliases: ["pattern", "files"],
    description: "Specify a pattern for matching files",
    valueHelp: "file_pattern"
  ),
  thisBranch(
    option: "source-branch",
    abbreviation: "t",
    aliases: ["branch-a"],
    description: "Specify the current branch",
    valueHelp: "branch name",
  ),
  otherBranch(
    option: "destination-branch",
    abbreviation: "o",
    aliases: ["branch-b"],
    description: "Specify the target branch",
    valueHelp: "branch name",
  ),
  thisSha(
    option: "source-sha",
    abbreviation: 'x',
    aliases: ["current-sha"],
    description: "Specify the current commit SHA",
    valueHelp: "current_sha",
  ),
  otherSha(
    option: "target-sha",
    abbreviation: "y",
    aliases: ["target-sha"],
    description: "Specify the target commit SHA",
    valueHelp: "target_sha"
  ),
  help(
    option: "help",
    abbreviation: "h",
    aliases: ["usage", "info"],
    description: "Display help and usage information",
    valueHelp: null
  ),
  verbose(
    option: "verbose",
    abbreviation: "v",
    aliases: ["debug"],
    description: "Display detailed debugging information",
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
