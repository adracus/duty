library duty.monad;

abstract class Monad<A> {
  const Monad();

  Monad map(transform(A value));
  Monad flatMap(transform(A value));
}

abstract class Option<A> extends Monad<A> {
  const Option() : super();

  bool get isDefined;
  bool get isEmpty;

  Option<A> map(transform(A value));
  Option<A> flatMap(transform(A value));
}

class Some<A> extends Option<A> {
  final A value;

  const Some(this.value) : super();

  Some<A> map(transform(A value)) => new Some(transform(value));

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

const None = Nothing.inst;

class Nothing extends Option<dynamic> {
  static const Nothing inst = const Nothing._internal();

  const Nothing._internal() : super();

  factory Nothing() => inst;

  bool get isDefined => false;
  bool get isEmpty => true;

  Nothing map(transform(dynamic value)) => this;
  Nothing flatMap(transform(dynamic value)) => this;

  bool operator==(other) => identical(this, other);

  String toString() => "None";
}
