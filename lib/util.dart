library duty.numeric;

import 'package:duty/match.dart' show ZeroArity;

Numeric n(num value) => new Numeric(value);

typedef _CountFn(int i);

class Numeric {
  final num value;

  Numeric(this.value);

  void times(f) {
    for (var i = 0; i < value.toInt(); i++) {
      if (f is _CountFn) f(i);
      if (f is ZeroArity) f();
    }
  }

  List map(f(int i)) => new List.generate(value, f);
}

List flatten(List l, [int level = - 1]) {
  if (0 == level) return l;
  return l.fold([], (List acc, cur) {
    if (cur is List) return acc..addAll(flatten(cur, level - 1));
    return acc..add(cur);
  });
}

bool equalLists(List l1, List l2) {
  final len = l1.length;
  if (len != l2.length) return false;

  for (var i = 0; i < len; i++) {
    var e1 = l1[i];
    var e2 = l2[i];

    var comp = e1 is List && e2 is List ? equalLists(e1, e2) : e1 == e2;
    if (!comp) return false;
  }

  return true;
}

reverse(reversable) {
  if (reversable is String) return reverseString(reversable);
  if (reversable is int) return int.parse(reverseString(reversable.toString()));
  if (reversable is Iterable) return reversable.toList().reversed;
  if (reversable is double)
    return double.parse(reverseString(reversable.toString()));
  throw new Exception("Cannot reverse $reversable");
}

min(Iterable it) {
  if (it.isEmpty) throw new StateError("Empty iterable");

  var minimum;
  for (var elem in it) {
    if (null == minimum || Comparable.compare(minimum, elem) > 0)
      minimum = elem;
  }

  return minimum;
}

max(Iterable it) {
  if (it.isEmpty) throw new StateError("Empty iterable");

  var maximum;
  for (var elem in it) {
    if (null == maximum || Comparable.compare(maximum, elem) < 0)
      maximum = elem;
  }

  return maximum;
}

double avg(Iterable<num> numbers) {
  if (numbers.isEmpty) return .0;
  var ct = 0;
  var sum = 0;

  for (var elem in numbers) {
    sum += elem;
    ct += 1;
  }

  return sum / ct;
}

String reverseString(String string) {
  return new String.fromCharCodes(string.codeUnits.reversed);
}
