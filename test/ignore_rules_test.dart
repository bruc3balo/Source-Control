import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:test/test.dart';

import 'balo_t.dart';

void main() {
  test('ignore rules', () {
    for (var e in IgnorePatternRules.values) {
      e.example.test();
    }
    debugPrintToConsole(message: "Ignore pattern tests passed");
  });

  test(
    'add to ignore file',
    () async {
      await testWithRepository(
        doTest: (localRepository, remoteRepository, v) async {
          // Show command help command
          int helpCode = await runTest([CliCommandsEnum.ignore.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
          assert(helpCode == 0);

          String expectedEntry = "*.dart";

          //Run add ignore files command
          int addToIgnoreCode = await runTest([
            CliCommandsEnum.ignore.command,
            "-${CliCommandOptionsEnum.add.abbreviation}",
            expectedEntry,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);

          assert(addToIgnoreCode == 0);

          //Check if ignore file exists and contains expectedEntry
          Ignore s = Ignore(localRepository);
          assert(s.ignoreFile.existsSync());
          assert(s.patternsToIgnore.contains(expectedEntry));

          //Run remove ignore files command
          int removeFromIgnoreCode = await runTest([
            CliCommandsEnum.ignore.command,
            "-${CliCommandOptionsEnum.remove.abbreviation}",
            expectedEntry,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);

          assert(removeFromIgnoreCode == 0);

          //Check if ignore file doesn't contains expectedEntry
          assert(s.ignoreFile.existsSync());
          assert(!s.patternsToIgnore.contains(expectedEntry));

          //Clean up ignore file
          s.deleteIgnoreFile();
          assert(!s.ignoreFile.existsSync());
        },
      );
    },
  );

  printToConsole(
    message: "Ignore test completed",
    color: CliColor.brightYellow,
    style: CliStyle.bold,
    newLine: true,
  );
}
