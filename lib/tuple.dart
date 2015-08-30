library duty.n_tuple;

/** Abstract class for a container of one or more values */
abstract class Tuple {
  /** Returns the values of this in an ordered list */
  List get values;
  /** maps all values of this with the transform function */
  List map(transform(a));
}

class Tuple1<A1> implements Tuple {
  final A1 v1;

  Tuple1(this.v1);

  List get values => [v1];

  List map(transform(a)) => values.map(transform);
}

class Tuple2<A1, A2> implements Tuple {
  final A1 v1;
  final A2 v2;

  Tuple2(this.v1, this.v2);

  List get values => [v1, v2];

  List map(transform(a)) => values.map(transform);
}

class Tuple3<A1, A2, A3> implements Tuple {
  final A1 v1;
  final A2 v2;
  final A3 v3;

  Tuple3(this.v1, this.v2, this.v3);

  List get values => [v1, v2, v3];

  List map(transform(a)) => values.map(transform);
}

/** Shorthand for creating a [Tuple1]. */
single(a) => new Tuple1(a);
/** Shorthand for creating a [Tuple2]. */
dual(a, b) => new Tuple2(a, b);
/** Shorthand for creating a [Tuple3]. */
triple(a, b, c) => new Tuple3(a, b, c);
