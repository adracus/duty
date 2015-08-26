library test.duty.map;

import 'package:duty/map.dart';
import 'package:duty/monad.dart';
import 'package:test/test.dart';

main() {
  group("Map", () {
    group("WrappedMap", () {
      group("get", () {
        final m = new WrappedMap<String, int>();
        m["a"] = 1;

        test("successfull get", () {
          expect(m.get("a"), equals(new Some(1)));
        });

        test("failure get", () {
          expect(m.get("b"), equals(None));
        });
      });
    });
  });
}
