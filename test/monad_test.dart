import 'package:duty/monad.dart';
import 'package:test/test.dart';

main() {
  group("Monad", () {
    group("Option", () {
      group("Some", () {
        final s = new Some(3);
        test("isDefined", () {
          expect(s.isDefined, isTrue);
        });

        test("isEmpty", () {
          expect(s.isEmpty, isFalse);
        });

        test("map", () {
          final mapped = s.map((n) => n * 3);

          expect(mapped, equals(new Some(9)));
        });

        test("flatMap", () {
          final mapped = s.map((n) => new Some(n * 3));

          expect(mapped, equals(new Some(new Some(9))));
        });
      });

      group("None", () {
        final n = new Nothing();

        test("singleton criteria", () {
          expect(n, equals(new Nothing()));
          expect(identical(n, new Nothing()), isTrue);
        });

        test("isDefined", () {
          expect(n.isDefined, isFalse);
        });

        test("isEmpty", () {
          expect(n.isEmpty, isTrue);
        });

        test("map", () {
          final mapped =
              n.map((u) => throw new Exception("This should not be thrown"));
          expect(mapped, equals(n));
        });

        test("flatMap", () {
          final mapped = n
              .flatMap((u) => throw new Exception("This should not be thrown"));

          expect(mapped, equals(n));
        });
      });
    });
  });
}
