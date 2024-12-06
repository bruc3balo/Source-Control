
///Representation of what a user inputs
abstract class UserInput {
  List<String> get originalUserInput;

  bool get isEmpty => originalUserInput.isEmpty;
}

///Implementation of [UserInput] from the command line
class CliUserInput extends UserInput {
  @override
  final List<String> originalUserInput;

  CliUserInput(this.originalUserInput);
}