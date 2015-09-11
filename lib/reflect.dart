library duty.reflect;

import 'dart:mirrors';
import 'dart:io' show Platform;

/** Invokes the named method on the given object with the specified arguments. */
invoke(Object on, String method, List positionalArguments,
    [Map namedArguments = const {}]) {
  final mirror = reflect(on);
  final result =
      mirror.invoke(new Symbol(method), positionalArguments, namedArguments);

  return result.reflectee;
}

/** Returns the list of superclasses of this type. */
List<ClassMirror> supersOf(Type type) {
  final mirror = reflectClass(type);
  final superClass = mirror.superclass;

  if (null == superClass) return [];
  return [superClass]..addAll(supersOf(superClass.reflectedType));
}

/** Returns the fields of the given class. Recurses into superclasses if
 * recursive is specified true. */
Set<DeclarationMirror> declarationsOf(Type type, {bool recursive: true}) {
  final classMirror = reflectClass(type);

  final fields = classMirror.declarations.values.toSet();
  if (!recursive) return fields;

  final supers = supersOf(type);
  return supers.fold(fields, (Set<DeclarationMirror> acc, ClassMirror cur) =>
      acc..addAll(cur.declarations.values));
}

/** Returns the current library that is used. */
LibraryMirror get currentLibrary =>
    currentMirrorSystem().libraries[Platform.script];

/** Returns all imports of this library. If deep, also recurses into imported
 * libraries. */
Set<LibraryMirror> importsOf(LibraryMirror library, {bool deep: true}) {
  var imports = library.libraryDependencies
      .where((dependency) => dependency.isImport && dependency is LibraryMirror)
      .map((dependency) => dependency as LibraryMirror)
      .toSet();

  if (!deep) return imports;
  return imports.fold(imports, (Set<LibraryMirror> acc, LibraryMirror current) {
    if (acc.contains(current)) return acc;
    return acc..addAll(importsOf(current, deep: true));
  });
}

/** Returns all classes that reside inside this library. If [recursive], also
 * returns all classes of imports of this library. */
Set<ClassMirror> classesOf(LibraryMirror library, {bool recursive: true}) {
  var classes = library.declarations.values
      .where((declaration) => declaration is ClassMirror)
      .toSet();

  if (!recursive) return classes;
  var imports = importsOf(library);
  return new Set.from(imports.fold(classes,
      (Set<ClassMirror> classes, LibraryMirror library) => classesOf(library)));
}

/** Stringifies the given object.
 *
 * If the given object is a [Symbol], returns the symbol's string value.
 * If the given object is a [Type], returns the type's simple name.
 * Otherwise, [toString] is called on the argument.
 */
String str(Object arg) {
  if (arg is Symbol) {
    return MirrorSystem.getName(arg);
  }

  if (arg is Type) {
    return str(reflectType(arg).simpleName);
  }

  return arg.toString();
}
