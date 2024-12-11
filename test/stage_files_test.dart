
import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:test/test.dart';
import 'balo_t.dart' as test_runner;

void main() {
  test('Stage files test', () async {
    // Do with repository
    await test_runner.testWithRepository(
      doTest: (r, _, v) async {

        // Show command help command
        int helpCode = await test_runner.runTest([CliCommandsEnum.add.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
        assert(helpCode == 0);

        String expectedFile = "/test/balo_t.dart";

        //Run stage files command
        int stageFilesCode = await test_runner.runTest([
          CliCommandsEnum.add.command,
          "-${CliCommandOptionsEnum.filePattern.abbreviation}",
          expectedFile,
          v ?"-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
        ]);

        assert(stageFilesCode == 0);

        //Check if staging file exists and contains test file
        Staging s = Staging(Branch(defaultBranch, r));
        assert(s.hasStagedFiles);
        assert(s.stagingData != null);
        assert(s.stagingData!.filesToBeStaged.contains(expectedFile));

        //Clean up staging file
        s.deleteStagingData();
        assert(!s.hasStagedFiles);
      },
    );

    printToConsole(
      message: "Stage files test completed",
      color: CliColor.brightYellow,
      style: CliStyle.bold,
      newLine: true,
    );
  });
}
