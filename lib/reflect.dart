library duty.reflect;

import 'dart:mirrors';

invoke(
  Object on,
  String method,
  List positionalArguments,
  [Map namedArguments = const {}]) {
    final mirror = reflect(on);
    final result = mirror.invoke(
      new Symbol(method),
      positionalArguments,
      namedArguments);

    return result.reflectee;
}
