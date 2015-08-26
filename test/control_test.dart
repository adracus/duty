library test.duty.control;

import 'package:test/test.dart';
import 'package:duty/control.dart';

main() {
  group("control", () {
    group("Try", () {
      test("successfull try", () {
        final result = Try(() => 10);
        expect(result, equals(new Success(10)));
      });

      test("failure try", () {
        final result = Try(() => throw new Exception("Errored"));
        expect(result is Failure, isTrue);
      });
    });

    group("Failure", () {
      final f = new Failure(new Exception("Some reason"));
      test("map", () {
        final mapped = f.map((a) => throw new Exception("Error"));
        expect(identical(f, mapped), isTrue);
      });

      test("flatMap", () {
        final mapped = f.flatMap((a) => throw new Exception("Error"));
        expect(identical(f, mapped), isTrue);
      });
    });

    group("Success", () {
      final s = new Success(10);

      test("map", () {
        final mapped = s.map((v) => v * 10);
        expect(mapped, equals(new Success(100)));
      });

      test("flatMap", () {
        final mapped = s.flatMap((v) => new Failure(new Exception("Some reason")));
        expect(mapped is Failure, isTrue);
      });
    });
  });
}
