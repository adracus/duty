library duty.control;

import 'match.dart';
import 'monad.dart';

abstract class Conditional {
  final Evaluatable condition;

  Conditional(this.condition);

  bool get isTrue => condition.evaluate() == true;

  call();
}

class IfElse extends Conditional {
  final Evaluatable ifBody;
  final Evaluatable elseBody;

  IfElse(Evaluatable condition, this.ifBody, this.elseBody): super(condition);

  Option call() => isTrue ? ifBody.evaluate() : elseBody.evaluate();
}

class When extends Conditional {
  final Evaluatable body;

  When(Evaluatable condition, this.body) : super(condition);

  call() => body.evaluate();
}

abstract class Result extends Monad {
  const Result() : super();

  bool get isSuccess;
  bool get isFailure;
}

class Success<E> extends Result {
  final E value;

  const Success(this.value);

  Success map(transform(arg)) => new Success(transform(value));

  Result flatMap(transform(arg)) {
    final transformed = transform(value);
    return transformed is Result ? transformed : new Success(transformed);
  }

  bool operator==(other) {
    if (other is! Success) return false;
    return other.value == this.value;
  }

  bool get isSuccess => true;
  bool get isFailure => false;
}

class Failure extends Result {
  final Exception reason;

  Failure(this.reason);

  Failure map(transform(arg)) => this;

  Failure flatMap(transform(arg)) => this;

  bool operator==(other) {
    if (other is! Failure) return false;
    return other.reason == this.reason;
  }

  bool get isSuccess => true;
  bool get isFailure => false;
}

Conditional If(condition, ifBody, {orElse}) {
  final conditionEvaluatable = new Evaluatable(condition);
  final ifBodyEvaluatable = new Evaluatable(ifBody);

  if (null == orElse) {
    return new When(conditionEvaluatable, ifBodyEvaluatable);
  }
  final elseBodyEvaluatable = new Evaluatable(orElse);
  return new IfElse(
    conditionEvaluatable,
    ifBodyEvaluatable,
    elseBodyEvaluatable);
}

Result Try(ZeroArity fn) {
  try {
    final result = fn();
    return new Success(result);
  } catch(e) {
    return new Failure(e);
  }
}
