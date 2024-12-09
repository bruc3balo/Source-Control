import 'package:balo/repository/ignore.dart';
import 'package:test/test.dart';

void main() {
  test('ignore rules', () {
    IgnorePatternRules.values.map((e) => e.example.test());
    print("All test passes");
  },);
}
