import 'command/command_mapper.dart';

class UserInput {
  final List<String> originalUserInput;

  UserInput(this.originalUserInput);

  bool get isEmpty => originalUserInput.isEmpty;

  String? get command =>
      originalUserInput.isEmpty ? null : originalUserInput.first;

  Map<String, String?> get optionsMap {
    Map<String, String?> optionsMap = {};

    for (int i = 1; i < originalUserInput.length; i + 2) {
      String optionKey = originalUserInput[i];
      int optionValueIndex = i + 1;

      String? value = optionValueIndex == originalUserInput.length
          ? null
          : originalUserInput[optionValueIndex];
      optionsMap.putIfAbsent(optionKey, () => value);
    }

    return optionsMap;
  }

  CommandOptionsMapperEnum? findByOption(String optionKey) =>
      CommandOptionsMapperEnum
          .commandOptionsMap[optionKey.toLowerCase().trim()];

  @override
  String toString() => """
  \nCommand: $command
  \nOptions: $optionsMap
  """;
}

extension UserInputX on UserInput {

  CommandMapperEnum? get commandEnum {
    String? inputCommand = command?.toLowerCase();
    if (inputCommand == null) return null;

    //Command map here
    return CommandMapperEnum.commandOptionsMap[inputCommand.toLowerCase().trim()];
  }

  Map<CommandOptionsMapperEnum, String?> get mapOptionsEnum {
    Map<CommandOptionsMapperEnum, String?> result = {};

    for (var m in optionsMap.entries) {
      String optionKey = m.key;

      CommandOptionsMapperEnum? optionEnum = findByOption(optionKey);
      if (optionEnum == null) continue;

      String? value = m.value;
      result.putIfAbsent(optionEnum, () => value);
    }

    return result;
  }

}
