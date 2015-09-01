library duty.list;

import 'dart:core' as core;

import 'package:duty/monad.dart';
import 'package:duty/match.dart';
import 'package:duty/map.dart';

/** A singly linked immutable list. Regard this implementation as rather
 * experimental. Comes with support for flattening, deep equal and other
 * monadic operations */
abstract class List<E> implements Monad<E>, core.Iterable<E> {
  factory List.empty() => Nil;

  factory List.from(core.List list) {
    List result = Nil;
    final iterator = list.reversed.iterator;
    while (iterator.moveNext()) {
      result = result.prepend(iterator.current);
    }
    return result;
  }

  core.bool get isEmpty;

  core.int get length;

  E get head;

  Option<E> get headOption;

  List<E> get tail;

  List<E> collect(PartialFunction pf);

  void forEach(void f(E value));

  List map(transform(E value));

  List flatMap(transform(E value));

  List<E> append(E element);

  List<E> appendAll(List<E> elements);

  List<E> prepend(E element);

  List<E> prependAll(List<E> elements);

  fold(initial, combine(previous, E element));

  core.bool any(core.bool test(E element));

  core.bool every(core.bool test(E element));

  core.String join([core.String separator = ""]);

  E _singleWhereInternal(Option<E> acc, core.bool test(E element));

  E _lastWhereInternal(
    Option<E> found,
    core.bool test(E element),
    E orElse);

  List get reversed;

  /** Creates a map out of this list by generating a key of each
   * element with the given extract function and putting each element
   * into a list with the matching key. */
  Map<dynamic, List> groupBy(extract(E element));

  core.Iterator<E> get iterator;

  E firstWhere(core.bool test(E elem), {orElse: Empty});
}

const List Nil = EmptyList.inst;

class EmptyList implements List {
  static const inst = const EmptyList._internal();

  final core.int length = 0;

  const EmptyList._internal();

  List get tail => throw new EmptyListAccess();

  Option get headOption => None;

  _lastWhereInternal(Option found, core.bool test(element), orElse) {
    if (found.isDefined) return found.get;
    return new Evaluatable(orElse).evaluate();
  }

  lastWhere(core.bool test(element), {orElse: Empty}) =>
      new Evaluatable(orElse).evaluate();

  List get head => throw new EmptyListAccess();

  get first => head;

  elementAt(core.int idx) => throw new EmptyListAccess();

  core.bool get isEmpty => true;

  core.bool get isNotEmpty => false;

  List get reversed => Nil;

  List collect(PartialFunction pf) => Nil;

  void forEach(f(e)) => null;

  List expand(core.Iterable exp(e)) => Nil;

  _singleWhereInternal(Option acc, core.bool test(element)) {
    if (acc.isDefined) return acc.get;
    throw new core.StateError("No element");
  }

  reduce(combine(value, element)) => throw new EmptyListAccess();

  List where(test(e)) => Nil;

  core.Set toSet() => new core.Set();

  get single => throw new EmptyListAccess();

  List skipWhile(core.bool test(element)) => Nil;

  List skip(core.int n) => Nil;

  singleWhere(test(e)) => throw new EmptyListAccess();

  get last => throw new EmptyListAccess();

  List take(core.int n) => Nil;

  List takeWhile(core.bool test(element)) => Nil;

  List map(transform(value)) => Nil;

  List flatMap(transform(value)) => Nil;

  List append(element) => new LinkedList(element);

  List appendAll(List elements) => elements;

  List prepend(element) => new LinkedList(element);

  List prependAll(List elements) => elements;

  fold(initial, combine(acc, element)) => initial;

  Map groupBy(extract(element)) => new Map.empty();

  core.bool any(core.bool test(element)) => false;

  core.bool every(core.bool test(element)) => true;

  core.String join([core.String separator = ""]) => "";

  core.List toList({core.bool growable: true}) => [];

  core.bool contains(core.Object element) => false;

  core.bool operator==(other) => other is EmptyList;

  core.Iterator get iterator => new ListIterator(this);

  firstWhere(core.bool test(elem), {orElse: Empty}) {
    return new Evaluatable(orElse).evaluate();
  }
}

class ListIterator<E> implements core.Iterator<E> {
  List _list;

  ListIterator(List list) : _list = list.prepend(null);

  core.bool moveNext() {
    if (Nil == _list.tail) return false;
    _list = _list.tail;
    return true;
  }

  E get current => _list.head;
}

class LinkedList<E> implements List<E> {
  final E head;
  final List<E> tail;

  LinkedList(this.head, [this.tail = Nil]);

  void forEach(f(E e)) {
    f(head);
    tail.forEach(f);
  }

  Option<E> get headOption => new Some(head);

  List collect(PartialFunction pf) {
    if (pf.isDefinedOn(head)) {
      return new LinkedList(pf(head), tail.collect(pf));
    }
    return tail.collect(pf);
  }

  E lastWhere(core.bool test(E element), {orElse: Empty}) =>
      _lastWhereInternal(None, test, orElse);

  E singleWhere(core.bool test(E element)) => _singleWhereInternal(None, test);

  E _singleWhereInternal(Option<E> acc, core.bool test(E element)) {
    if (test(head)) {
      if (acc.isDefined) throw new core.StateError("Too many elements");
      return tail._singleWhereInternal(new Some(head), test);
    }
    return tail._singleWhereInternal(acc, test);
  }

  List<E> get reversed => tail.fold(new LinkedList(head), (List<E> acc, cur) {
    return acc.prepend(cur);
  });

  core.Iterable expand(core.Iterable f(E element)) =>
      new ExpandIterable(this, f);

  core.bool contains(E element) {
    if (element == head) return true;
    return tail.contains(element);
  }

  E _lastWhereInternal(
    Option<E> found,
    core.bool test(E element),
    E orElse) {
      if (test(head)) {
        return tail._lastWhereInternal(new Some(head), test, orElse);
      }
      return tail._lastWhereInternal(found, test, orElse);
  }

  List skipWhile(core.bool test(E element)) {
    if (test(head)) return tail.skipWhile(test);
    return this;
  }

  List skip(core.int n) {
    if (n < 0) throw new core.ArgumentError("n cannot be < 0");
    if (n == 0) return this;
    return tail.skip(n - 1);
  }

  E get first => head;

  E get single {
    if (Nil == tail) return head;
    throw new core.StateError("More than one element");
  }

  core.Set<E> toSet() => fold(new core.Set<E>(), (core.Set<E> acc, elem) =>
      acc..add(elem));

  List<E> take(core.int n) {
    if (n < 0) throw new core.ArgumentError("n cannot be < 0");
    if (n == 0) return Nil;
    return new LinkedList(head, tail.take(n - 1));
  }

  List<E> takeWhile(core.bool test(E e)) {
    if (test(head)) return new LinkedList(head, tail.takeWhile(test));
    return Nil;
  }

  E elementAt(core.int n) {
    if (n < 0) throw new core.ArgumentError("n cannot be < 0");
    if (n == 0) return head;
    return tail.elementAt(n - 1);
  }

  core.List<E> toList({core.bool growable: true}) =>
      fold([], (core.List<E> list, e) => list..add(e));

  List<E> where(core.bool test(E e)) {
    if (test(head)) return new LinkedList(head, tail.where(test));
    return tail.where(test);
  }

  E get last => Nil == tail ? head : tail.last;

  core.bool get isNotEmpty => false;

  core.Iterator<E> get iterator => new ListIterator(this);

  List map(transform(E value)) {
    final transformedHead = transform(head);
    return new LinkedList(transformedHead, tail.map(transform));
  }

  E reduce(E combine(E value, E element)) => tail.fold(head, combine);

  List flatMap(transform(E value)) {
    final transformedHead = transform(head);
    if (transformedHead is List) {
      return tail.flatMap(transform).prependAll(transformedHead);
    }
    return new LinkedList(transformedHead, tail.flatMap(transform));
  }

  List<E> append(E element) {
    if (tail.isEmpty) return new LinkedList(head, new LinkedList(element));
    return new LinkedList(head, tail.append(element));
  }

  List<E> appendAll(List<E> elements) {
    if (tail.isEmpty) return new LinkedList(head, elements);
    return new LinkedList(head, tail.appendAll(elements));
  }

  Map groupBy(extract(E element)) => fold(new Map.empty(), (Map acc, E elem) {
    final extracted = extract(elem);
    List<E> current = acc.getOrElse(extracted, new List<E>.empty());
    current = current.append(elem); // TODO: reduce n runtime here
    acc[extracted] = current;
    return acc;
  });

  List<E> prepend(E element) => new LinkedList(element, this);

  List<E> prependAll(List<E> elements) => elements.appendAll(this);

  E firstWhere(core.bool test(E element), {orElse: Empty}) {
    if (test(head)) return head;
    return tail.firstWhere(test, orElse: orElse);
  }

  core.bool any(core.bool test(E element)) {
    if (test(head)) return true;
    return tail.any(test);
  }

  core.bool every(core.bool test(E element)) {
    if (!test(head)) return false;
    return tail.every(test);
  }

  fold(initial, combine(acc, E element)) =>
      tail.fold(combine(initial, head), combine);

  core.int get length => 1 + tail.length;

  core.bool get isEmpty => false;

  core.String join([core.String separator = ""]) =>
      head.toString() + tail.fold("", (acc, cur) {
    return acc + separator + cur.toString();
  });

  core.bool operator==(other) {
    if (other is! List<E>) return false;
    return this.head == other.head && this.tail == other.tail;
  }

  core.String toString() => "LinkedList(${join(", ")})";
}

class EmptyListAccess implements core.Exception {
  core.String toString() => "Cannot access empty list";
}

typedef core.Iterable<T> _ExpandFunction<S, T>(S sourceElement);

class ExpandIterable<S, T> extends core.Iterable<T> {
  final core.Iterable<S> _iterable;
  final _ExpandFunction _f;

  ExpandIterable(this._iterable, core.Iterable<T> this._f(S element));

  core.Iterator<T> get iterator => new ExpandIterator<S, T>(_iterable.iterator, _f);
}

class ExpandIterator<S, T> implements core.Iterator<T> {
  final core.Iterator<S> _iterator;
  final _ExpandFunction _f;
  // Initialize _currentExpansion to an empty iterable. A null value
  // marks the end of iteration, and we don't want to call _f before
  // the first moveNext call.
  core.Iterator<T> _currentExpansion = const EmptyIterator();
  T _current;

  ExpandIterator(this._iterator, core.Iterable<T> this._f(S element));

  T get current => _current;

  core.bool moveNext() {
    if (_currentExpansion == null) return false;
    while (!_currentExpansion.moveNext()) {
      _current = null;
      if (_iterator.moveNext()) {
        // If _f throws, this ends iteration. Otherwise _currentExpansion and
        // _current will be set again below.
        _currentExpansion = null;
        _currentExpansion = _f(_iterator.current).iterator;
      } else {
        return false;
      }
    }
    _current = _currentExpansion.current;
    return true;
  }
}

/** The always empty iterator. */
class EmptyIterator<E> implements core.Iterator<E> {
  const EmptyIterator();
  core.bool moveNext() => false;
  E get current => null;
}
