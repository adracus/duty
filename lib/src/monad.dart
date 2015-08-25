library duty.monad;

abstract class Monad<A> {
  Monad map(transform(A value));
}

abstract class Option<A> extends Monad<A> {
  bool get isDefined;
  bool get isEmpty;

  Option<A> map(transform(A value));
  Option<A> flatMap(transform(A value));
}

class Some<A> extends Option<A> {
  final A value;

  Some(this.value);

  Option<A> map(transform(A value)) => new Some(transform(value));

  Option<A> flatMap(transform(A value)) {
    final transformed = transform(value);
    return transformed is Option ? transformed : new Some(transformed);
  }

  bool get isDefined => true;
  bool get isEmpty => false;

  bool operator ==(other) {
    if (other is! Some<A>) return false;
    return other.value == this.value;
  }

  String toString() => "Some($value)";
}

class None extends Option<dynamic> {
  static None _inst = new None._internal();

  None._internal();

  factory None() {
    return _inst;
  }

  bool get isDefined => false;
  bool get isEmpty => true;

  None map(transform(dynamic value)) => this;
  None flatMap(transform(dynamic value)) => this;

  bool operator==(other) => identical(this, other);

  String toString() => "None";
}
