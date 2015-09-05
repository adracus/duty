library duty.numeric;

import 'dart:collection' show IterableMixin, IterableBase;

import 'package:duty/match.dart' show ZeroArity;

/** Wraps the given value in a [Numeric] container. */
Numeric n(num value) => new Numeric(value);

typedef _CountFn(int i);

/** Additional utility operations with numbers */
class Numeric {
  final num value;

  Numeric(this.value);

  /** Invokes [f] [value] times. If [f] accepts an integer argument, passes
   * the index of the current iteration to it. Otherwise only invokes [f]. */
  void times(f) {
    for (var i = 0; i < value.toInt(); i++) {
      if (f is _CountFn) f(i);
      if (f is ZeroArity) f();
    }
  }

  /** Returns a range from [value] to [end], exclusive. */
  NumericRange to(num end, [num step = 1]) =>
      new NumericRangeInclusive(value, end, step);

  /** Returns a range from [value] to [end], inclusive. */
  NumericRange until(num end, [num step = 1]) =>
      new NumericRangeExclusive(value, end, step);

  /** Shorthand for [List].generate. */
  List map(f(int i)) => new List.generate(value, f);

  bool operator ==(other) => other is Numeric ? value == other.value : false;
}

/** Flattens the given list and nested lists.
 *
 * By default this does a deep flattening meaning that all nested lists
 * will be added to a single result list. [level] can also be adjusted
 * to specify the depth of flattening. */
List flatten(List l, [int level = -1]) {
  if (0 == level) return l;
  return l.fold([], (List acc, cur) {
    if (cur is List) return acc..addAll(flatten(cur, level - 1));
    return acc..add(cur);
  });
}

/** Checks if the given lists are deeply equal. */
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

/** Reverses the given argument.
 *
 * For strings, the characters are rotated.
 *
 * For integers, the integer is first converted into a string and then reversed.
 * After this, the string is parsed as an integer
 *
 * For doubles, the same procedure as for integers applies.
 *
 * For iterables, the iterable is converted to a list and then reversed.
 *
 * For all other objects, this throws. */
reverse(reversable) {
  if (reversable is String) return reverseString(reversable);
  if (reversable is int) return int.parse(reverseString(reversable.toString()));
  if (reversable is Iterable) return reversable.toList().reversed;
  if (reversable is double) return double
      .parse(reverseString(reversable.toString()));
  throw new Exception("Cannot reverse $reversable");
}

/** Extracts the minimum element of an iterable. */
min(Iterable it) {
  if (it.isEmpty) throw new StateError("Empty iterable");

  var minimum;
  for (var elem in it) {
    if (null == minimum || Comparable.compare(minimum, elem) > 0) minimum =
        elem;
  }

  return minimum;
}

/** Extracts the maximum element of an iterable. */
max(Iterable it) {
  if (it.isEmpty) throw new StateError("Empty iterable");

  var maximum;
  for (var elem in it) {
    if (null == maximum || Comparable.compare(maximum, elem) < 0) maximum =
        elem;
  }

  return maximum;
}

/** Calculates the average of the given iterable. */
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

/** Reverses the characters of the given string. */
String reverseString(String string) {
  return new String.fromCharCodes(string.codeUnits.reversed);
}

/** Range between a start and an end value. */
abstract class Range<E> implements Iterable {
  /** Start value of the range. */
  E get start;
  /** End value of the range. */
  E get end;

  /** Checks if the given value lies within the range. */
  bool contains(E value);
}

/** Range for numeric start and end values. */
abstract class NumericRange implements Range<num> {
  num get start;
  num get end;
  num get step;
  num get difference;
}

/** Base class for exclusive and inclusive numeric ranges. */
abstract class NumericRangeBase extends IterableBase<num>
    implements NumericRange {
  final num start;
  final num end;
  final num step;

  num get difference => (start - end).abs();

  NumericRangeBase(this.start, this.end, num step)
      : step = step == 0 ? throw new ArgumentError("step cannot be 0") : step;

  bool get isEmpty => (end - start) / step <= 0;

  bool _sameParameters(NumericRange other) {
    return step == other.step && end == other.end && start == other.start;
  }
}

/** Range from [start] to [end], exclusive. */
class NumericRangeInclusive extends NumericRangeBase {
  NumericRangeInclusive(num start, num end, [num step = 1])
      : super(start, end, step);

  NumericRangeIterator get iterator => new NumericRangeIterator(this);

  bool contains(num n) {
    if (isEmpty) return false;
    final diff = n - start;
    final steps = diff / step;
    if (steps < 0) return false;
    final intDiff = steps.toInt() * step;
    if (intDiff != diff) return false;
    final val = intDiff + start;
    return val <= end;
  }

  bool operator ==(other) {
    if (other is! NumericRangeInclusive) return false;
    return _sameParameters(other);
  }

  String toString() => "Range.inclusive($start, $end, step = $step)";
}

/** Range from [start] to [end], exclusive. */
class NumericRangeExclusive extends NumericRangeBase {
  NumericRangeExclusive(num start, num end, [num step = 1])
      : super(start, end, step);

  NumericRangeIterator get iterator => new NumericRangeIterator(this);

  bool contains(num n) {
    if (isEmpty) return false;
    final diff = n - start;
    final steps = diff / step;
    if (steps < 0) return false;
    final intDiff = steps.toInt() * step;
    if (intDiff != diff) return false;
    final val = intDiff + start;
    return val < end;
  }

  bool operator ==(other) =>
      other is NumericRangeExclusive ? _sameParameters(other) : false;

  String toString() => "Range.exclusive($start, $end, step = $step)";
}

/** Iterator for numeric ranges. */
class NumericRangeIterator extends Iterator<num> {
  final NumericRange on;
  num _current;

  NumericRangeIterator(NumericRange on)
      : on = on,
        _current = on.start;

  num get current => _current;

  bool moveNext() {
    if (on.contains(current)) {
      _current += on.step;
      return true;
    }
    return false;
  }
}
