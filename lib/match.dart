library duty.match;

import 'package:duty/monad.dart' show None, Option, Some;

typedef bool Predicate(arg);
typedef ThenFunction(arg);
typedef ZeroArity();

/** Empty constant. Throws if put into an [Evaluatable]. */
const _Empty Empty = const _Empty();

/** Cannot be evaluated if put into an [Evaluatable]. */
class _Empty {
  const _Empty();
}

/** Filters [on] for element that [fn] is defined on and maps them with [fn]. */
List collect(Iterable on, PartialFunction fn) {
  var result = [];
  for (final elem in on) {
    if (fn.isDefinedOn(elem)) {
      result.add(fn(elem));
    }
  }
  return result;
}

class Then {
  final fn;

  const Then(this.fn);

  call(arg) {
    if (fn is ThenFunction) return fn(arg);
    return fn;
  }
}

typedef Option Lifted(arg);

/** A function that is defined on some values */
class PartialFunction {
  final List<Matcher> _matchers;

  PartialFunction(this._matchers);

  /** Returns a new [PartialFunction] with the matcher added */
  PartialFunction add(Matcher matcher) {
    return new PartialFunction([]
      ..addAll(_matchers)
      ..add(matcher));
  }

  /** Returns a builder for a partial function that also matches on
   * [condition] */
  PartialFunctionExtension when(condition) =>
      new PartialFunctionExtension(this, new Condition(condition));

  /** Tests if this function can be called on [obj] */
  bool isDefinedOn(Object obj) =>
      _matchers.any((matcher) => matcher.matches(obj));

  /** Turns this into a regular function that returns a Some if this
   * is defined on a value and a None else. */
  Lifted get lift => (arg) {
    if (this.isDefinedOn(arg)) return new Some(this(arg));
    return None;
  };

  /** Gets the first matching matcher and executes its body */
  call(Object on) => _matchers
      .firstWhere((matcher) => matcher.matches(on),
          orElse: () => throw new Exception(""))
      .then(on);
}

/** Extension for a [PartialFunction] [origin] that will match on [condition]. */
class PartialFunctionExtension {
  final PartialFunction origin;
  final Condition condition;

  PartialFunctionExtension(this.origin, this.condition);

  /** Body that is executedd once the condition is satisfied. */
  PartialFunction then(then) {
    final matcher = new CustomMatcher(condition, new Then(then));
    if (null == origin) return new PartialFunction([matcher]);
    return origin.add(matcher);
  }
}

/** An exception if no possible matcher could be found for [on]. */
class MatchingException {
  final on;
  MatchingException(this.on);

  String toString() => "Could not match $on";
}

/** A matcher which has a condition and evaluates if it matches */
abstract class Matcher {
  /** Evaluates this and returns the result */
  then(arg);

  /** Checks if the condition matches the given argument */
  bool matches(arg);

  factory Matcher(Condition condition, Then _then) = CustomMatcher;
}

/** Matcher that matches on arguments of a specific type */
class TypeMatcher<E> implements Matcher {
  final Then _then;

  TypeMatcher(this._then);

  bool matches(arg) => arg is E;

  then(arg) => _then(arg);
}

class CustomMatcher implements Matcher {
  /** Condition of this matcher */
  final Condition condition;
  /** Evaluatable body of this matcher */
  final Then _then;

  CustomMatcher(this.condition, this._then);

  bool matches(arg) => condition.matches(arg);

  then(arg) => _then(arg);
}

/** Condition which can be either a constant or a [Predicate] */
class Condition {
  final content;

  Condition(this.content);

  /** If [content] is a constant, this checks for equality and returns the
   * result. If [content] is a [Predicate], the argument is given to the
   * [Predicate] and the result of the invocation is returned. */
  bool matches(arg) => content is Predicate ? content(arg) : arg == content;
}

/** Simple evaluatable argument. Can be either a [ZeroArity] or a constant. */
class Evaluatable {
  /** Content of this evaluatable. Either a [ZeroArity] or a constant. */
  final content;

  Evaluatable(this.content);

  /** If content is a [ZeroArity], invokes and returns the result. Otherwise,
   * returns [content]. */
  evaluate() {
    if (Empty == content) {
      throw new StateError("Cannot evaluate empty");
    }
    return content is ZeroArity ? content() : content;
  }
}

/** Function that always returns true */
always(condition) => true;

/** Shorthand for creating a new pattern match */
match(arg, PartialFunction fn) => fn(arg);

PartialFunctionExtension when(condition) =>
    new PartialFunctionExtension(null, new Condition(condition));
