import 'dart:io';

import 'package:balo/view/themes.dart';
import 'package:dart_console/dart_console.dart';

final Console console = Console();
bool isVerboseMode = true;

String? listenForInput({String? title}) {
  //Write title
  if (title != null) printToConsole(message: title, color: CliColor.blue);

  //Prompt writing
  printToConsole(message: "> ");

  //Get input
  return stdin.readLineSync(retainNewlines: true);
}

void debugPrintToConsole({
  required String message,
  bool newLine = false,
  CliColor color = CliColor.magenta,
  CliStyle? style,
  TextAlignment alignment = TextAlignment.left,
}) {
  if (!isVerboseMode) return;
  printToConsole(
    message: message,
    newLine: newLine,
    color: color,
    style: style,
    alignment: alignment,
  );
}

void printToConsole({
  required String message,
  bool newLine = false,
  CliColor color = CliColor.defaultColor,
  CliStyle? style,
  TextAlignment alignment = TextAlignment.left,
}) {
  String data =
      '${newLine ? '\n' : ''}${color.color}${style?.style ?? ''}$message${CliColor.defaultColor.color}';
  console.writeLine(data, alignment);
}