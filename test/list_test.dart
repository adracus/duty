library test.duty.list;

import 'package:duty/list.dart';
import 'package:test/test.dart';
import 'package:duty/map.dart' as duty;
import 'package:duty/match.dart' show when;

main() {
  group("List", () {
    group("Empty list", () {
      test("head", () {
        expect(() => Nil.head, throws);
      });

      test("tail", () {
        expect(() => Nil.tail, throws);
      });

      test("isEmpty", () {
        expect(Nil.isEmpty, isTrue);
      });
    });

    group("LinkedList", () {
      var l = new LinkedList(1, new LinkedList(2, new LinkedList(3)));

      test("head", () {
        expect(l.head, equals(1));
      });

      test("prependAll", () {
        expect(l.prependAll(new LinkedList(-1, new LinkedList(0))), equals(
            new LinkedList(-1, new LinkedList(
                0, new LinkedList(1, new LinkedList(2, new LinkedList(3)))))));
      });

      test("prepend", () {
        expect(l.prepend(0), equals(new LinkedList(
            0, new LinkedList(1, new LinkedList(2, new LinkedList(3))))));
      });

      test("append", () {
        expect(l.append(4), equals(new LinkedList(
            1, new LinkedList(2, new LinkedList(3, new LinkedList(4))))));
      });

      test("appendAll", () {
        expect(l.appendAll(new LinkedList(4, new LinkedList(5))), equals(
            new LinkedList(1, new LinkedList(
                2, new LinkedList(3, new LinkedList(4, new LinkedList(5)))))));
      });

      test("tail", () {
        expect(l.tail == new LinkedList(2, new LinkedList(3)), isTrue);
      });

      test("isEmpty", () {
        expect(l.isEmpty, isFalse);
      });

      test("groupBy", () {
        final map = l.groupBy((n) => n >= 2 ? 1 : 0);
        final compare = new duty.Map();
        compare[0] = new LinkedList(1);
        compare[1] = new LinkedList(2, new LinkedList(3));

        expect(compare == map, isTrue);
      });

      group("firstWhere", () {
        test("success", () {
          expect(l.firstWhere((n) => n >= 2), equals(2));
        });

        test("fail", () {
          expect(() => l.firstWhere((n) => n > 10), throws);
        });

        test("orElse", () {
          expect(l.firstWhere((n) => n > 10, orElse: 10), equals(10));
        });
      });

      test("fold", () {
        expect(l.fold(0, (a, b) => a + b), equals(6));
      });

      test("collect", () {
        final collected = l.collect(when((n) => n >= 2).then(10));

        expect(collected == new LinkedList(10, new LinkedList(10)), isTrue);
      });

      test("reduce", () {
        expect(l.reduce((a, b) => a + b), equals(6));
      });

      test("any", () {
        expect(l.any((n) => n == 2), isTrue);
        expect(l.any((n) => n > 10), isFalse);
      });

      test("every", () {
        expect(l.every((n) => n < 10), isTrue);
        expect(l.every((n) => n > 10), isFalse);
      });

      test("join", () {
        expect(l.join(", "), equals("1, 2, 3"));
        expect(new LinkedList(1).join(), equals("1"));
      });

      test("map", () {
        final mapped = l.map((n) => n * n);
        expect(mapped,
            equals(new LinkedList(1, new LinkedList(4, new LinkedList(9)))));
      });

      test("flatMap", () {
        final mapped = l.flatMap((n) => new LinkedList(n));
        expect(mapped,
            equals(new LinkedList(1, new LinkedList(2, new LinkedList(3)))));
      });

      test("forEach", () {
        var sum = 0;
        l.forEach((n) => sum += n);
        expect(sum, equals(6));
      });

      test("lastWhere", () {
        expect(l.lastWhere((n) => n >= 2), equals(3));
        expect(l.lastWhere((n) => n > 3, orElse: 4), equals(4));
        expect(() => l.lastWhere((n) => n > 3), throws);
      });

      test("singleWhere", () {
        expect(l.singleWhere((n) => n == 2), equals(2));
        expect(() => l.singleWhere((n) => n >= 2), throws);
      });

      test("contains", () {
        expect(l.contains(2), isTrue);
        expect(l.contains(0), isFalse);
      });

      test("skip", () {
        expect(l.skip(1), equals(new LinkedList(2, new LinkedList(3))));
        expect(() => l.skip(-1), throws);
        expect(l.skip(10), equals(Nil));
      });

      test("skipWhile", () {
        expect(l.skipWhile((n) => n < 3), equals(new LinkedList(3)));
        expect(l.skipWhile((n) => n < 10), equals(Nil));
      });

      test("take", () {
        expect(l.take(1), equals(new LinkedList(1)));
        expect(() => l.take(-1), throws);
        expect(l.take(30), equals(l));
      });

      test("takeWhile", () {
        expect(l.takeWhile((n) => n < 2), equals(new LinkedList(1)));
        expect(l.takeWhile((n) => n < 10), equals(l));
      });

      test("single", () {
        expect(() => l.single, throws);
        expect(new LinkedList(1).single, equals(1));
      });

      test("elementAt", () {
        expect(l.elementAt(2), equals(3));
        expect(() => l.elementAt(-1), throws);
        expect(() => l.elementAt(3), throws);
      });

      test("where", () {
        expect(l.where((int n) => n.isEven), equals(new LinkedList(2)));
      });
    });
  });
}
