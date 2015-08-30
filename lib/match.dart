library duty.match;

typedef bool Predicate(arg);
typedef ZeroArity();

/** Empty constant. Throws if put into an [Evaluatable]. */
const _Empty Empty = const _Empty();

/** Cannot be evaluated if put into an [Evaluatable]. */
class _Empty {
  const _Empty();
}

/** Matches an object according to specified functions or constants
 *
 * Example:
 *
 *     match(5).when((n) => n < 2).then(print("Is smaller than 2"))
               .when((n) => n == 5).then(print("It is five!"))
               (); // Prints "It is five!"
 */
class PatternMatch {
  /** The object against which is matched */
  final Object on;

  /** The matchers that have been defined on this */
  final List<Matcher> matchers = [];

  PatternMatch(this.on);

  /** Constructs an additional matcher on this pattern match */
  MatcherBuilder when(condition) =>
      new MatcherBuilder(new Condition(condition), this);

  /** Adds a matcher to this pattern match */
  void add(Matcher matcher) => matchers.add(matcher);

  /** Invokes this pattern match and returns the result of the first matching
   * matcher */
  call() {
    return matchers.firstWhere((matcher) => matcher.matches(on),
        orElse: () => throw new Exception("")).then();
  }

  /** Alias for call */
  run() => call();
}

/** An exception if no possible matcher could be found for [on]. */
class MatchingException {
  final on;
  MatchingException(this.on);

  String toString() => "Could not match $on";
}

class MatcherBuilder {
  final Condition condition;
  final PatternMatch origin;

  MatcherBuilder(this.condition, this.origin);

  /** Creates a matcher which evaluates [evaluatable] if [condition] is
   * fullfilled. */
  PatternMatch then(evaluatable) {
    final matcher = new Matcher(condition, new Evaluatable(evaluatable));
    origin.add(matcher);

    return origin;
  }
}

/** A matcher which has a condition and evaluates if it matches */
class Matcher {
  /** Condition of this matcher */
  final Condition condition;
  /** Evaluatable body of this matcher */
  final Evaluatable evaluatable;

  Matcher(this.condition, this.evaluatable);

  /** Checks if the condition matches the given argument */
  bool matches(arg) => condition.matches(arg);

  /** Evaluates the [Evaluatable] of this and returns the result */
  then() => evaluatable.evaluate();
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
PatternMatch match(Object arg) => new PatternMatch(arg);
