import 'package:flutter/material.dart';

import '../data.dart';

class Parameter<T> extends ValueNotifier<T> {
  Parameter({
    required this.name,
    required T value,
    required List<String> parentPath,
  }) : super(value = value) {
    path = [...parentPath, name];
    show.addListener(
      () =>
          Data.memory.setString(_showPath().toString(), show.value.toString()),
    );
    init();
  }

  final String name;
  late final List<String> path;
  final show = ValueNotifier<bool>(false);

  void init() {
    final data = Data.memory.getString(_showPath().toString());
    if (data != null) show.value = data == "true";
  }

  List<String> _showPath() {
    return [...path, "Show"];
  }
}

class PersistentParameter<T> extends Parameter<T> {
  PersistentParameter({
    required super.name,
    required super.value,
    required super.parentPath,
  });

  @override
  set value(T newValue) {
    Data.memory.setString(path.toString(), stringify(newValue));
    super.value = newValue;
  }

  @override
  void init() {
    super.init();
    final data = Data.memory.getString(path.toString());
    if (data != null) {
      value = fromString(data);
    }
  }

  T fromString(String str) {
    if (T == bool) return (str == "true") as T;
    if (T == String) return str as T;
    if (T == int) return int.parse(str) as T;
    if (T == double) return double.parse(str) as T;
    throw UnimplementedError(
      "Type ${T.runtimeType} no Persistent parameter parser",
    );
  }

  String stringify(T val) {
    if (T == bool) return val.toString();
    if (T == String) return val.toString();
    if (T == int) return val.toString();
    if (T == double) return val.toString();
    throw UnimplementedError(
      "Type ${T.runtimeType} no Persistent parameter stringify",
    );
  }
}
