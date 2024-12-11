import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:test/test.dart';

import 'balo_t.dart';

void main() {
  test('initialize repository test', () async {
    await testWithRepository(
      doTest: (r, _, v) async {
        // Show command help command
        int helpCode = await runTest([CliCommandsEnum.init.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
        assert(helpCode == 0);
      },
    );

    debugPrintToConsole(
      message: "Initialize repository test completed",
      color: CliColor.brightYellow,
      style: CliStyle.bold,
      newLine: true,
    );
  });
}
