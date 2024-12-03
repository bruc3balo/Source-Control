import 'package:balo/command/command.dart';
import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/branch.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/state.dart';
import 'package:balo/variables.dart';


// Facade class
class RepositoryInitializer {
  final String? path;

  RepositoryInitializer(this.path);

  List<Command> initialize() {
    if (path == null) {
      return [ShowErrorCommand("Path required")];
    }

    // Initialize the repository and related objects
    Repository repository = Repository(path!);
    Ignore ignore = Ignore(repository);
    Branch branch = Branch(defaultBranch, repository);
    State state = State(repository, branch.directory.path);

    // Return the list of commands
    return [
      InitializeRepositoryCommand(repository: repository),
      CreateIgnoreFileCommand(ignore),
      CreateStateFileCommand(state),
      CreateNewBranchCommand(branch),
    ];
  }

}


