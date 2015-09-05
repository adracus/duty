library duty.monad;

import 'package:duty/match.dart';

/** A container embodying state. */
abstract class Monad<A> {
  /** Transforms the content of this if this is a non-empty container.
   * Returns the content wrapped in the container. */
  Monad map(transform(A value));
  /** Transforms the content of this if this is a non-empty container.
   * If the result of the transformation is a new container of same kind,
   * returns the container. Otherwise returns the result wrapped in a
   * container. */
  Monad flatMap(transform(A value));
}

/** A container which can either be a present value in form of [Some] or an
 * absent value in form of [Nothing]. */
abstract class Option<A> implements Monad<A> {
  /** Returns whether this has a value or in other words is a [Some]. */
  bool get isDefined;
  /** Returns whether this does not have a value and is a [Nothing]. */
  bool get isEmpty;

  /** Returns the value of this. If this is a [Nothing], throws an exception. */
  A get get;

  /** Returns the value of this or if this is not defined. returns the
   * evaluation of [orElse] */
  A getOrElse(orElse);

  /** Returns this if this is defined or otherwise the evaluation of alternative
   * which has to be an option itself. */
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

const Nothing None = Nothing.inst;

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

  bool operator ==(other) => identical(this, other);

  String toString() => "None";
}
