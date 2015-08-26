import 'package:duty/match.dart';
import 'package:test/test.dart';


main() {
  group("Match", () {
    group("match", () {
      group("call", () {
        test("Successfull match", () {
          final m = match(5)
            .when((n) => n > 10)
            .then(10)
            .when((n) => n < 10)
            .then(0);

          expect(m(), equals(0));
        });

        test("Failure match", () {
          final m = match(5)
            .when((n) => n > 10).then(20);

          expect(() => m(), throws);
        });

        test("Matching order", () {
          final m = match(5)
            .when(always).then(10)
            .when((n) => n <= 5).then(0);

          expect(m(), equals(10));
        });
      });
    });

    group("Condition", () {
      group("matches", () {
        test("constant condition", () {
          final c = new Condition(1);

          expect(c.matches(1), isTrue);
          expect(c.matches(2), isFalse);
        });

        test("predicate condition", () {
          final c = new Condition((int test) => test.isEven);

          expect(c.matches(5), isFalse);
          expect(c.matches(6), isTrue);
        });
      });
    });

    group("Evaluatable", () {
      group("evaluate", () {
        test("constant content", () {
          final e = new Evaluatable(10);

          expect(e.evaluate(), equals(10));
        });

        test("ZeroArity content", () {
          final e = new Evaluatable(() => 10);

          expect(e.evaluate(), equals(10));
        });
      });
    });
  });
}
