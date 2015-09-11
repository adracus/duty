# duty [![Build Status](https://travis-ci.org/Adracus/duty.svg?branch=master)](https://travis-ci.org/Adracus/duty)
Your code calls for your duty! Write clear, efficient code with this library.

This library is divided into eight parts:

## `monad.dart`

This part includes the basic `Monad` class for all monads.

`Option` is a class representing the presence or the absence of a value.
The presence is indicated by the class `Some` and the absence is represented
by `None`, an instance of class nothing. `Option` can be used in conjunction
with `duty.Map` or with `duty.List`.

## `map.dart`

This part comes with a better implementation of a map: The `WrappedMap` is an
iterable of `Tuple2`s. It enables O(1) access to values by keys.

`DefaultMap` behaves like `Map` but if a value is not present, the configurable
default function of the map is invoked and returns a value.

## `match.dart`

A library part made for pattern matching.

Using `match(arg, PartialFunction pf)`, a pattern match can be started.
A partial function is a function that is defined for some input arguments
and for some not. To easily create a partial function, call the
`when(condition)` method. This returns a `PartialFunctionExtension`.
A condition can be either a constant or a `Predicate`, functions of form
`bool test(arg) =>`. They match if the function returns true or if the
constant is equal to the argument.
If a function is defined on an input argument, its body is invoked. The
body is a `Then`, either a function of type `(arg) => value` or a constant.

`Evaluatable`s contains a value that is either a function of form `() =>` or
an other value. If the value is a function, `evaluate` returns its result.
Otherwise, it returns the value directly.

## `tuple.dart`

Tuples are typesafe containers for one or more values. Currently,
`Tuple1`, `Tuple2` and `Tuple3` are implemented.

## `control.dart`

Control flow implementations are in this part of the library.

`IfElse` consists of a `Condition` and an `ifBody` and an `elseBody`.
`call()` evaluates to the result of the `ifBody` if the condition evaluates
to true and the `elseBody` otherwise.

`When` is like `ifElse` but it only has a `body`. It returns an `Option`
which is either `Some` if the `When` was true and None otherwise.

`Result` is the result of a computation which can be either a `Success`
or a `Failure`. This wraps the `try-catch` construct inside program logic.
To wrap a closure of form `() =>` into either a `Success` or a `Failure`,
pass it to `Try(fn)`.

## `util.dart`

`util.dart` comes with several utility functions:

`n(num a)` wraps a `num` inside a `Numeric` container. This offers
functions such as `times` which executes a given function `value` times.
`map` on `Numeric` is a shorthand for `List.generate`.

`to` and `until` invoked on a `Numeric` return a `NumericRangeInclusive`
or a `NumericRangeExclusive`. These Ranges provide lazy iterables, as such
it is possible to define ranges like `n(0).to(double.INFINITY)`. For a range,
a step width can be additionally specified, defaulting to `1`.

`flatten` flattens a nested list. Additionally, a `level` can be specified
how deep the flattening is applied. For negative numbers, the flattening
flattens all nested lists.

`equalLists` checks if two lists are equal. Nested lists are also checked
with this method.

`reverse` reverses the given argument in a correct manner:
If the argument is a `String`, a string with the characters reversed is returned.
If the argument is an `int`, the int is first converted to a `String`,
then reversed and then parsed as an `int`. The same applies for `double`s.
`Iterable`s are converted to a list which is then reversed.

`max` extracts the maximum value out of an iterable with comparables.
`min` extracts the minimum.

`avg` calculates the average of a list of `num`s.

## `reflect.dart`

This part of the library is quite experimental. It provides support when using
reflection:

`invoke` takes an object, a method name and parameters. It then generically invokes
the specified method on the object and returns the result.

`supersOf` returns all superclasses of the given type.

`declarationsOf` returns all declarations of the given type. If `recursive` is
specified as true, declarations of parent classes are also added.

`currentLibrary` returns the `LibraryMirror` of the currently running script.

`importsOf` returns all imports of the given library. It can also be specified
to recursively collect imports of imported libraries.

`classesOf` takes a `LibraryMirror` and returns all classes contained in that
library. It can also be specified to recursively collect all classes from all
linked libraries.

`str` is an improved `toString` method: For `Symbol`s, it returns the string
value of the symbol, for `Type`s, it returns the simple name of the type. For
all other arguments, it invokes and returns the result of `toString`.
