library test.duty.map;

import 'package:duty/map.dart';
import 'package:duty/monad.dart';
import 'package:test/test.dart';

main() {
  group("Map", () {
    group("WrappedMap", () {
      final m = new WrappedMap<String, int>();
      m["a"] = 1;
      group("get", () {
        test("hit", () {
          expect(m.get("a"), equals(new Some(1)));
        });

        test("miss", () {
          expect(m.get("b"), equals(None));
        });
      });

      group("[]", () {
        test("hit", () {
          expect(m["a"], equals(1));
        });

        test("miss", () {
          expect(() => m["b"], throws);
        });
      });

      group("getOrElse", () {
        test("hit", () {
          expect(m.getOrElse("a", 3), equals(1));
        });

        test("miss", () {
          expect(m.getOrElse("b", 3), equals(3));
        });
      });

      group("containsKey", () {
        test("hit", () {
          expect(m.containsKey("a"), isTrue);
        });

        test("miss", () {
          expect(m.containsKey("b"), isFalse);
        });
      });

      group("==", () {
        test("same", () {
          var m2 = new WrappedMap();
          m2["a"] = 1;

          expect(m, equals(m2));
        });

        test("not same", () {
          var m2 = new WrappedMap();

          expect(m == m2, isFalse);
        });
      });

      group("sameContent", () {
        test("same", () {
          var m2 = new WrappedMap();
          m2["a"] = 1;

          expect(m.sameContent(m2), isTrue);
        });

        test("not same", () {
          var m2 = new WrappedMap();

          expect(m.sameContent(m2), isFalse);
        });
      });
    });

    group("DefaultMap", () {
      final m = new DefaultMap<String, int>((String key) => key.length);
      m["a"] = 1;
      group("get", () {
        test("hit", () {
          expect(m.get("a"), equals(new Some(1)));
        });

        test("miss", () {
          expect(m.get("test"), equals(new Some(4)));
        });
      });

      group("[]", () {
        test("hit", () {
          expect(m["a"], equals(1));
        });

        test("miss", () {
          expect(m["b"], equals(1));
        });
      });

      group("getOrElse", () {
        test("hit", () {
          expect(m.getOrElse("a", 3), equals(1));
        });

        test("miss", () {
          expect(m.getOrElse("b", 10), equals(10));
        });
      });

      group("containsKey", () {
        test("hit", () {
          expect(m.containsKey("a"), isTrue);
        });

        test("miss", () {
          expect(m.containsKey("b"), isFalse);
        });
      });

      group("==", () {
        test("same", () {
          var m2 = new DefaultMap((String key) => key.length);
          m2["a"] = 1;

          expect(m, equals(m2));
        });

        test("not same", () {
          var m2 = new DefaultMap((String key) => key.length);

          expect(m == m2, isFalse);
        });
      });

      group("sameContent", () {
        test("same", () {
          var m2 = new WrappedMap();
          m2["a"] = 1;

          expect(m.sameContent(m2), isTrue);
        });

        test("not same", () {
          var m2 = new WrappedMap();

          expect(m.sameContent(m2), isFalse);
        });
      });
    });
  });
}
