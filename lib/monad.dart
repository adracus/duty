library duty.monad;

import 'package:duty/match.dart';

abstract class Monad<A> {
  Monad map(transform(A value));
  Monad flatMap(transform(A value));
}

abstract class Option<A> implements Monad<A> {
  bool get isDefined;
  bool get isEmpty;

  A get get;
  A getOrElse(orElse);
  Option<A> orElse(alternative);
  Option<A> map(transform(A value));
  Option<A> flatMap(transform(A value));
}

class Some<A> implements Option<A> {
  final A value;

  const Some(this.value);

  Some<A> map(transform(A value)) => new Some(transform(value));

  Option<A> flatMap(transform(A value)) {
    final transformed = transform(value);
    return transformed is Option ? transformed : new Some(transformed);
  }

  A get get => value;
  A getOrElse(orElse) => value;

  Option<A> orElse(alternative) => this;

  bool get isDefined => true;
  bool get isEmpty => false;

  bool operator ==(other) {
    if (other is! Some<A>) return false;
    return other.value == this.value;
  }

  String toString() => "Some($value)";
}

const None = Nothing.inst;

class Nothing implements Option<dynamic> {
  static const Nothing inst = const Nothing._internal();

  const Nothing._internal();

  factory Nothing() => inst;

  get get => throw new Exception("Cannot get from None");

  bool get isDefined => false;
  bool get isEmpty => true;

  getOrElse(orElse) => new Evaluatable(orElse).evaluate();

  Option orElse(alternative) => new Evaluatable(alternative).evaluate();

  Nothing map(transform(dynamic value)) => this;
  Nothing flatMap(transform(dynamic value)) => this;

  bool operator==(other) => identical(this, other);

  String toString() => "None";
}
