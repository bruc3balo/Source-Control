import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:test/test.dart';
import 'balo_t.dart' as test_runner;

void main() {
  test('Show help test', () async {
    List<String> arguments = [CliCommandsEnum.help.command];

    int code = await test_runner.runTest(arguments);
    assert(code == 0);

    debugPrintToConsole(
      message: "Show help test completed",
      color: CliColor.brightYellow,
      style: CliStyle.reversed,
      newLine: true,
    );
  });
}
