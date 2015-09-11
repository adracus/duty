library duty.n_tuple;

/** Abstract class for a container of one or more values */
abstract class Tuple {
  /** Returns the values of this in an ordered list */
  List get values;

  /** maps all values of this with the transform function */
  List map(transform(a));

  static final _numericConstructors = {
    1: (List l) => new Tuple1(l.single),
    2: (List l) => new Tuple2(l[0], l[1]),
    3: (List l) => new Tuple3(l[0], l[1], l[2])
  };

  factory Tuple.from(Iterable iterable) {
    var list = iterable.toList();
    return _numericConstructors[list.length](list);
  }

  Tuple get reversed;
}

abstract class _TupleMixin implements Tuple {
  List map(transform(a)) => values.map(transform);

  Tuple get reversed => new Tuple.from(values.reversed);
}

class Tuple1<A1> extends Object with _TupleMixin implements Tuple {
  final A1 v1;

  Tuple1(this.v1);

  List get values => [v1];
}

class Tuple2<A1, A2> extends Object with _TupleMixin implements Tuple {
  final A1 v1;
  final A2 v2;

  Tuple2(this.v1, this.v2);

  List get values => [v1, v2];
}

class Tuple3<A1, A2, A3> extends Object with _TupleMixin implements Tuple {
  final A1 v1;
  final A2 v2;
  final A3 v3;

  Tuple3(this.v1, this.v2, this.v3);

  List get values => [v1, v2, v3];
}

class TupleCreator {
  const TupleCreator();

  Tuple noSuchMethod(Invocation invocation) {
    if (invocation.isMethod && #call == invocation.memberName) {
      /* No positional arguments should have been passed. */
      assert(invocation.namedArguments.isEmpty);
      var args = invocation.positionalArguments;
      return new Tuple.from(args);
    }
    return super.noSuchMethod(invocation);
  }

  /** Shorthand for creating a [Tuple1]. */
  one(a) => new Tuple1(a);

  /** Shorthand for creating a [Tuple2]. */
  two(a, b) => new Tuple2(a, b);

  /** Shorthand for creating a [Tuple3]. */
  three(a, b, c) => new Tuple3(a, b, c);
}

const TupleCreator tuple = const TupleCreator();
