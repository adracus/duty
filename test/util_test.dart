library test.duty.numeric;

import 'package:duty/util.dart';
import 'package:test/test.dart';

main() {
  group("util", () {
    group("Numeric", () {
      group("times", () {
        test("==", () {
          expect(new Numeric(1), equals(new Numeric(1)));
          expect(new Numeric(1), isNot(equals(new Numeric(2))));
        });

        test("n", () {
          expect(new Numeric(1), equals(n(1)));
        });

        test("ZeroArity", () {
          var sum = 0;
          n(5).times(() => sum += 1);
          expect(sum, equals(5));
        });

        test("Count Function", () {
          var l = [];
          n(3).times((i) => l.add(i));
          expect(l.length, equals(3));
          expect(l[0], equals(0));
          expect(l[1], equals(1));
          expect(l[2], equals(2));
        });

        test("to", () {
          expect(n(5).to(10), equals(new NumericRangeInclusive(5, 10)));
        });

        test("until", () {
          expect(n(5).until(10), equals(new NumericRangeExclusive(5, 10)));
        });
      });
    });

    group("equalLists", () {
      group("unequal lists", () {
        test("different size", () {
          final l1 = [1, 2];
          final l2 = [3];

          expect(equalLists(l1, l2), isFalse);
        });

        test("equal size, different elements", () {
          final l1 = [1, 2, 3];
          final l2 = [3, 5, 6];

          expect(equalLists(l1, l2), isFalse);
        });

        test("equal size, different order", () {
          final l1 = [1, 2, 3];
          final l2 = [3, 2, 1];

          expect(equalLists(l1, l2), isFalse);
        });
      });

      group("equal lists", () {
        test("equal elements and order", () {
          final l1 = [1, 2, 3];
          final l2 = [1, 2, 3];

          expect(equalLists(l1, l2), isTrue);
        });

        test("equal elements (also lists themselves)", () {
          final l1 = [1, 2, [3, [4]]];
          final l2 = [1, 2, [3, [4]]];

          expect(equalLists(l1, l2), isTrue);
        });
      });
    });

    group("flatten", () {
      final l = [1, 2, [3, 4, [5, 6]]];

      test("flatten one level", () {
        expect(flatten(l, 1), equals([1, 2, 3, 4, [5, 6]]));
      });

      test("deep flatten", () {
        expect(flatten(l), equals([1, 2, 3, 4, 5, 6]));
      });

      test("zero flatten", () {
        expect(flatten(l, 0), equals(l));
      });
    });

    group("reverse", () {
      test("int", () {
        expect(reverse(1234), equals(4321));
      });

      test("String", () {
        expect(reverse("abc"), equals("cba"));
      });

      test("double", () {
        expect(reverse(123.345), equals(543.321));
      });

      test("iterable", () {
        expect(reverse([1, 2, 3]), equals([3, 2, 1]));
      });
    });

    test("min", () {
      expect(min([10, 4, 100, -3]), equals(-3));
      expect(() => min([]), throws);
    });

    test("max", () {
      expect(max([10, 4, 100, -3]), equals(100));
      expect(() => max([]), throws);
    });

    test("avg", () {
      expect(avg([]), equals(0));
      expect(avg([4, 3, 2, 1]), equals(2.5));
    });

    group("Range", () {
      group("NumericRangeInclusive", () {
        final r = new NumericRangeInclusive(0, 10, 2);

        test("contains", () {
          expect(r.contains(-1), isFalse);
          expect(r.contains(0), isTrue);
          expect(r.contains(10), isTrue);
          expect(r.contains(6), isTrue);
          expect(r.contains(5), isFalse);
          expect(r.contains(11), isFalse);
          expect(r.contains(12), isFalse);
        });

        test("isEmpty", () {
          expect(r.isEmpty, isFalse);
          expect(new NumericRangeInclusive(0, 0), isEmpty);
          expect(new NumericRangeInclusive(0, -1), isEmpty);
        });

        test("==", () {
          final other1 = new NumericRangeInclusive(0, 10, 2);
          final other2 = new NumericRangeInclusive(0, 10, 1);
          final other3 = new NumericRangeInclusive(1, 10, 2);
          final other4 = new NumericRangeInclusive(0, 11, 2);
          final other5 = new NumericRangeInclusive(1, 11, 2);

          expect(r == other1, isTrue);
          expect(r == other2, isFalse);
          expect(r == other3, isFalse);
          expect(r == other4, isFalse);
          expect(r == other5, isFalse);
        });
      });

      group("NumericRangeExclusive", () {
        final r = new NumericRangeExclusive(0, 3, 2);

        test("contains", () {
          expect(r.contains(-1), isFalse);
          expect(r.contains(0), isTrue);
          expect(r.contains(1), isFalse);
          expect(r.contains(2), isTrue);
          expect(r.contains(3), isFalse);
          expect(r.contains(4), isFalse);
        });

        test("isEmpty", () {
          expect(r.isEmpty, isFalse);
          expect(new NumericRangeExclusive(0, 0), isEmpty);
          expect(new NumericRangeExclusive(0, 1, 2), isNotEmpty);
        });

        test("==", () {
          final other1 = new NumericRangeExclusive(0, 3, 2);
          final other2 = new NumericRangeExclusive(0, 3, 1);
          final other3 = new NumericRangeExclusive(1, 3, 2);
          final other4 = new NumericRangeExclusive(0, 4, 2);
          final other5 = new NumericRangeExclusive(1, 5, 2);

          expect(r == other1, isTrue);
          expect(r == other2, isFalse);
          expect(r == other3, isFalse);
          expect(r == other4, isFalse);
          expect(r == other5, isFalse);
        });
      });
    });
  });
}
