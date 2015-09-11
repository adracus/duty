library test.duty.reflect;

import 'dart:math' show pow;
import 'dart:io' show Platform;
import 'dart:mirrors';

import 'package:test/test.dart';
import 'package:duty/reflect.dart';

class Exponentiator {
  static final name = "^n";

  final int value;

  Exponentiator(this.value);

  int calc({int exponent: 1}) => pow(value, exponent).toInt();
  int call(int exponent) => calc(exponent: exponent);
  int exponentiate([int exponent = 1]) => call(exponent);
}

main() {
  group("reflect", () {
    test("invoke", () {
      final e = new Exponentiator(2);

      expect(invoke(e, "call", [2]), equals(4));
      expect(invoke(e, "exponentiate", [2]), equals(4));
      expect(invoke(e, "calc", [], {#exponent: 2}), equals(4));
    });

    test("supersOf", () {
      final supers =
          supersOf(Exponentiator).map((s) => s.reflectedType).toList();

      expect(supers, equals([Object]));
    });

    group("declarationsOf", () {
      test("non-recursive", () {
        final fields = declarationsOf(Exponentiator, recursive: false)
            .map((declaration) => declaration.simpleName)
            .toSet();

        expect(fields, equals(new Set.from(
            [#name, #value, #calc, #exponentiate, #Exponentiator, #call])));
      });

      test("recursive", () {
        final fields = declarationsOf(Exponentiator, recursive: true)
            .map((declaration) => str(declaration.simpleName))
            .toSet();

        expect(fields, equals(new Set.from([
          "_hashCodeRnd",
          "==",
          "hashCode",
          "toString",
          "noSuchMethod",
          "runtimeType",
          "Object",
          "name",
          "value",
          "calc",
          "exponentiate",
          "Exponentiator",
          "call"
        ])));
      });
    });

    test("currentLibrary", () {
      expect(currentLibrary.uri, equals(Platform.script));
    });

    test("classesOf", () {
      final library =
          currentMirrorSystem().findLibrary(new Symbol("test.duty.reflect"));

      final classes = classesOf(library);
      expect(classes, equals(new Set.from([reflectClass(Exponentiator)])));
    });

    test("str", () {
      expect(str(#test), equals("test"));
      expect(str(Exponentiator), equals("Exponentiator"));
      expect(str(1), equals("1"));
    });
  });
}
