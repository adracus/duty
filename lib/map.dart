library duty.hashmap;

import 'dart:core' as core;
import 'dart:collection' show IterableMixin;

import 'package:duty/monad.dart';
import 'package:duty/tuple.dart';

abstract class Map<K, V> implements core.Iterable<Tuple2<K, V>> {
  factory Map() = WrappedMap;

  Option<V> get(K key);

  V operator[](K key);

  operator[]=(K key, V value);

  V getOrElse(K key, orElse);
}

class WrappedMap<K, V> extends core.Object with IterableMixin<Tuple2<K, V>>
    implements Map<K, V> {
  final _values = new core.Map<K, Tuple2<K, V>>();

  Option<V> get(K key) {
    final value = _values[key];
    if (null == value) return None;
    return new Some(value.v2);
  }

  V operator[](K key) => _values[key].v2;

  operator[]=(K key, V value) => _values[key] = dual(key, value);

  V getOrElse(K key, orElse) => get(key).getOrElse(orElse);

  core.Iterator<Tuple2<K, V>> get iterator => _values.values.iterator;
}

class DefaultMap<K, V> extends core.Object with IterableMixin<Tuple2<K, V>>
  implements Map<K, V> {

  final Map<K, V> _wrapped = new Map<K, V>();
  final _defaultFn;

  DefaultMap(V defaultFn(K key))
    : _defaultFn = defaultFn;

  Option<V> get(K key) => _wrapped.get(key).orElse(_defaultFn(key));

  V operator[](K key) => get(key).get;

  operator[]=(K key, V value) => _wrapped[key] = value;

  V getOrElse(K key, orElse) => get(key).getOrElse(orElse);

  core.Iterator<Tuple2<K, V>> get iterator => _wrapped.iterator;
}
