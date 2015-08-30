library duty.control;

import 'match.dart';
import 'monad.dart';

/** Conditional structures as objects */
abstract class Conditional {
  /** The condition of this [Conditional]. Can be either a function of
   * zero arity or a constant */
  final Evaluatable condition;

  Conditional(this.condition);

  /** Checks if the condition evaluates to the boolean constant true */
  bool get isTrue => condition.evaluate() == true;

  /** Invokes the appropriate body of this [Conditional] */
  call();
}

/** If else conditional structure in code */
class IfElse extends Conditional {
  /** Statement that will execute if this is true */
  final Evaluatable ifBody;
  /** Statement that will execute if this is not true */
  final Evaluatable elseBody;

  IfElse(Evaluatable condition, this.ifBody, this.elseBody): super(condition);

  call() => isTrue ? ifBody.evaluate() : elseBody.evaluate();
}

/** When conditional that will return an [Option] of the evaluated body */
class When extends Conditional {
  /* Statement that will execute if this is true */
  final Evaluatable body;

  When(Evaluatable condition, this.body) : super(condition);

  call() => isTrue ? new Some(body.evaluate()) : None;
}

/** Result of a computation */
abstract class Result<E> implements Monad {
  /** True if this computation succeeded without exceptions */
  bool get isSuccess;
  /** True if this computation had some errors */
  bool get isFailure;
}

/** Successfull computation */
class Success<E> implements Result<E> {
  /** The value which was computed */
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

/** Computation which had some errors */
class Failure implements Result {
  /** The reason for the failure */
  final reason;

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

/** Creates [When] when only ifBody is specified, otherwise creates an
 * [IfElse]. */
Conditional If(condition, ifBody, {orElse: Empty}) {
  final conditionEvaluatable = new Evaluatable(condition);
  final ifBodyEvaluatable = new Evaluatable(ifBody);

  if (Empty == orElse) {
    return new When(conditionEvaluatable, ifBodyEvaluatable);
  }
  final elseBodyEvaluatable = new Evaluatable(orElse);
  return new IfElse(
    conditionEvaluatable,
    ifBodyEvaluatable,
    elseBodyEvaluatable);
}

/** Wraps the closure into either [Success] or [Failure], depending if
 * there were errors in the computation or not. */
Result Try(ZeroArity fn) {
  try {
    final result = fn();
    return new Success(result);
  } catch(e) {
    return new Failure(e);
  }
}
