import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spikey/components/io/gpio/io_dummy.dart';
import 'package:spikey/data.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Data.memory = await SharedPreferences.getInstance();
  });

  group('DummyReadComponent', () {
    test('initial state is false', () {
      final c = DummyReadComponent(name: 'TestRead', parentPath: []);
      expect(c.state.value, false);
    });

    test('isDummy is true', () {
      final c = DummyReadComponent(name: 'TestRead', parentPath: []);
      expect(c.isDummy, true);
    });

    test('state is in parameter list', () {
      final c = DummyReadComponent(name: 'TestRead', parentPath: []);
      expect(c.parameter.contains(c.state), true);
    });

    test('has all expected functions', () {
      final c = DummyReadComponent(name: 'TestRead', parentPath: []);
      final names = c.functions.map((f) => f.name).toList();
      expect(names, containsAll(['Log Value', 'Fake ON', 'Fake OFF', '1sec cycle', 'Stop cycle']));
    });

    test('has Switch widget', () {
      final c = DummyReadComponent(name: 'TestRead', parentPath: []);
      expect(c.widgets.any((w) => w.name == 'Switch'), true);
    });

    test('Fake ON sets state to true', () {
      final c = DummyReadComponent(name: 'TestRead', parentPath: []);
      c.functions.singleWhere((f) => f.name == 'Fake ON').function();
      expect(c.state.value, true);
    });

    test('Fake OFF sets state to false', () {
      final c = DummyReadComponent(name: 'TestRead', parentPath: []);
      c.state.value = true;
      c.functions.singleWhere((f) => f.name == 'Fake OFF').function();
      expect(c.state.value, false);
    });

    test('1sec cycle toggles state, Stop cycle interrupts immediately', () {
      fakeAsync((fake) {
        final c = DummyReadComponent(name: 'TestRead', parentPath: []);
        c.functions.singleWhere((f) => f.name == '1sec cycle').function();

        expect(c.state.value, true); // set immediately on start

        fake.elapse(const Duration(seconds: 1));
        expect(c.state.value, false);

        fake.elapse(const Duration(seconds: 1));
        expect(c.state.value, true);

        // Stop mid-delay — completer fires instantly, loop exits without toggling
        c.functions.singleWhere((f) => f.name == 'Stop cycle').function();
        fake.elapse(const Duration(seconds: 2));
        expect(c.state.value, true); // state unchanged, loop exited immediately
      });
    });
  });

  group('DummyWriteComponent', () {
    test('initial state is false', () {
      final c = DummyWriteComponent(name: 'TestWrite', parentPath: []);
      expect(c.state.value, false);
    });

    test('state is in parameter list', () {
      final c = DummyWriteComponent(name: 'TestWrite', parentPath: []);
      expect(c.parameter.contains(c.state), true);
    });

    test('has ON and OFF functions', () {
      final c = DummyWriteComponent(name: 'TestWrite', parentPath: []);
      final names = c.functions.map((f) => f.name).toList();
      expect(names, containsAll(['ON', 'OFF']));
    });

    test('has Switch widget', () {
      final c = DummyWriteComponent(name: 'TestWrite', parentPath: []);
      expect(c.widgets.any((w) => w.name == 'Switch'), true);
    });

    test('ON function sets state to true', () {
      final c = DummyWriteComponent(name: 'TestWrite', parentPath: []);
      c.functions.singleWhere((f) => f.name == 'ON').function();
      expect(c.state.value, true);
    });

    test('OFF function sets state to false', () {
      final c = DummyWriteComponent(name: 'TestWrite', parentPath: []);
      c.state.value = true;
      c.functions.singleWhere((f) => f.name == 'OFF').function();
      expect(c.state.value, false);
    });

    test('setting state directly persists', () {
      final c = DummyWriteComponent(name: 'TestWrite', parentPath: []);
      c.state.value = true;
      expect(c.state.value, true);
    });
  });
}
