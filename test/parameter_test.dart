import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spikey/components/parameter.dart';
import 'package:spikey/data.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Data.memory = await SharedPreferences.getInstance();
  });

  group('Parameter<int>', () {
    test('stores initial value', () {
      final p = Parameter<int>(name: 'P', value: 42, parentPath: []);
      expect(p.value, 42);
    });

    test('value can be changed', () {
      final p = Parameter<int>(name: 'P', value: 0, parentPath: []);
      p.value = 99;
      expect(p.value, 99);
    });

    test('notifies listeners on change', () {
      final p = Parameter<int>(name: 'P', value: 0, parentPath: []);
      int calls = 0;
      p.addListener(() => calls++);
      p.value = 5;
      expect(calls, 1);
    });
  });

  group('Parameter<double>', () {
    test('stores initial value', () {
      final p = Parameter<double>(name: 'P', value: 3.14, parentPath: []);
      expect(p.value, 3.14);
    });

    test('value can be changed', () {
      final p = Parameter<double>(name: 'P', value: 0.0, parentPath: []);
      p.value = 1.5;
      expect(p.value, 1.5);
    });

    test('notifies listeners on change', () {
      final p = Parameter<double>(name: 'P', value: 0.0, parentPath: []);
      int calls = 0;
      p.addListener(() => calls++);
      p.value = 2.0;
      expect(calls, 1);
    });
  });

  group('Parameter<String>', () {
    test('stores initial value', () {
      final p = Parameter<String>(name: 'P', value: 'hello', parentPath: []);
      expect(p.value, 'hello');
    });

    test('value can be changed', () {
      final p = Parameter<String>(name: 'P', value: '', parentPath: []);
      p.value = 'world';
      expect(p.value, 'world');
    });

    test('notifies listeners on change', () {
      final p = Parameter<String>(name: 'P', value: '', parentPath: []);
      int calls = 0;
      p.addListener(() => calls++);
      p.value = 'changed';
      expect(calls, 1);
    });
  });

  group('Parameter — shared behaviour', () {
    test('path is parentPath + name', () {
      final p = Parameter<int>(name: 'Count', value: 0, parentPath: ['Root', 'Child']);
      expect(p.path, ['Root', 'Child', 'Count']);
    });

    test('show starts as false', () {
      final p = Parameter<int>(name: 'P', value: 0, parentPath: []);
      expect(p.show.value, false);
    });

    test('userEditable defaults to false', () {
      final p = Parameter<int>(name: 'P', value: 0, parentPath: []);
      expect(p.userEditable.value, false);
    });

    test('userEditable can be set to true', () {
      final p = Parameter<int>(name: 'P', value: 0, parentPath: [], userEditable: true);
      expect(p.userEditable.value, true);
    });

    test('show persists to memory when changed', () {
      final p = Parameter<int>(name: 'Count', value: 0, parentPath: ['Root']);
      p.show.value = true;
      expect(Data.memory.getString('[Root, Count, Show]'), 'true');
    });

    test('show restores from memory on construction', () async {
      await Data.memory.setString('[Count, Show]', 'true');
      final p = Parameter<int>(name: 'Count', value: 0, parentPath: []);
      expect(p.show.value, true);
    });
  });

  group('PersistentParameter<int>', () {
    test('stores initial value', () {
      final p = PersistentParameter<int>(name: 'P', value: 7, parentPath: []);
      expect(p.value, 7);
    });

    test('persists to memory when set', () {
      final p = PersistentParameter<int>(name: 'Count', value: 0, parentPath: []);
      p.value = 42;
      expect(Data.memory.getString('[Count]'), '42');
    });

    test('restores value from memory on construction', () async {
      await Data.memory.setString('[Count]', '99');
      final p = PersistentParameter<int>(name: 'Count', value: 0, parentPath: []);
      expect(p.value, 99);
    });
  });

  group('PersistentParameter<double>', () {
    test('stores initial value', () {
      final p = PersistentParameter<double>(name: 'P', value: 1.5, parentPath: []);
      expect(p.value, 1.5);
    });

    test('persists to memory when set', () {
      final p = PersistentParameter<double>(name: 'Duty', value: 0.0, parentPath: []);
      p.value = 0.75;
      expect(Data.memory.getString('[Duty]'), '0.75');
    });

    test('restores value from memory on construction', () async {
      await Data.memory.setString('[Duty]', '0.25');
      final p = PersistentParameter<double>(name: 'Duty', value: 0.0, parentPath: []);
      expect(p.value, 0.25);
    });
  });

  group('PersistentParameter<bool>', () {
    test('stores initial value', () {
      final p = PersistentParameter<bool>(name: 'P', value: false, parentPath: []);
      expect(p.value, false);
    });

    test('persists to memory when set', () {
      final p = PersistentParameter<bool>(name: 'Flag', value: false, parentPath: []);
      p.value = true;
      expect(Data.memory.getString('[Flag]'), 'true');
    });

    test('restores value from memory on construction', () async {
      await Data.memory.setString('[Flag]', 'true');
      final p = PersistentParameter<bool>(name: 'Flag', value: false, parentPath: []);
      expect(p.value, true);
    });
  });

  group('PersistentParameter<String>', () {
    test('stores initial value', () {
      final p = PersistentParameter<String>(name: 'P', value: 'hi', parentPath: []);
      expect(p.value, 'hi');
    });

    test('persists to memory when set', () {
      final p = PersistentParameter<String>(name: 'Label', value: '', parentPath: []);
      p.value = 'test';
      expect(Data.memory.getString('[Label]'), 'test');
    });

    test('restores value from memory on construction', () async {
      await Data.memory.setString('[Label]', 'restored');
      final p = PersistentParameter<String>(name: 'Label', value: '', parentPath: []);
      expect(p.value, 'restored');
    });
  });
}
