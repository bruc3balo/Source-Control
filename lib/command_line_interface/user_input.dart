///Representation of what a user inputs
abstract class UserInput {
  List<String> get originalUserInput;

  bool get isEmpty => originalUserInput.isEmpty;
}

///Implementation of [UserInput] from the command line
class CliUserInput extends UserInput {

  ///This list should not be modified
  @override
  final List<String> originalUserInput;

  CliUserInput(List<String> originalUserInput) : originalUserInput = List.unmodifiable(originalUserInput);
}
