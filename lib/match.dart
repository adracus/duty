library duty.match;

typedef bool Predicate(arg);
typedef ZeroArity();

class PatternMatch {
  final Object on;
  final List<Matcher> matchers = [];

  PatternMatch(this.on);

  MatcherBuilder when(condition) =>
      new MatcherBuilder(new Condition(condition), this);

  void add(Matcher matcher) => matchers.add(matcher);

  call() {
    return matchers.firstWhere((matcher) => matcher.matches(on),
        orElse: () => throw new Exception("")).then();
  }

  run() => call();
}

class MatchingException {
  final on;
  MatchingException(this.on);

  String toString() => "Could not match $on";
}

class MatcherBuilder {
  final Condition condition;
  final PatternMatch origin;

  MatcherBuilder(this.condition, this.origin);

  PatternMatch then(evaluatable) {
    final matcher = new Matcher(condition, new Evaluatable(evaluatable));
    origin.add(matcher);

    return origin;
  }
}

class Matcher {
  final Condition condition;
  final Evaluatable evaluatable;

  Matcher(this.condition, this.evaluatable);

  bool matches(arg) => condition.matches(arg);
  then() => evaluatable.evaluate();
}

class Condition {
  final content;

  Condition(this.content);

  bool matches(arg) => content is Predicate ? content(arg) : arg == content;
}

class Evaluatable {
  final content;

  Evaluatable(this.content);

  evaluate() => content is ZeroArity ? content() : content;
}

always(condition) => true;

PatternMatch match(Object arg) => new PatternMatch(arg);
