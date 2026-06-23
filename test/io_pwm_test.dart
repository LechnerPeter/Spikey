import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spikey/components/io/pwm/pwm_dummy.dart';
import 'package:spikey/data.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Data.memory = await SharedPreferences.getInstance();
  });

  group('DummyPwm', () {
    test('initial frequency is 1000', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      expect(c.frequency.value, 1000);
    });

    test('initial duty is 0.5', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      expect(c.duty.value, 0.5);
    });

    test('initial enabled is false', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      expect(c.enabled.value, false);
    });

    test('isDummy is true', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      expect(c.isDummy, true);
    });

    test('frequency, duty, enabled are in parameter list', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      expect(c.parameter.contains(c.frequency), true);
      expect(c.parameter.contains(c.duty), true);
      expect(c.parameter.contains(c.enabled), true);
    });

    test('has all expected functions', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      final names = c.functions.map((f) => f.name).toList();
      expect(names, containsAll(['ON', 'OFF', 'Halve', 'Double']));
    });

    test('has Slider widget', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      expect(c.widgets.any((w) => w.name == 'Slider'), true);
    });

    test('ON sets enabled to true', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      c.functions.singleWhere((f) => f.name == 'ON').function();
      expect(c.enabled.value, true);
    });

    test('OFF sets enabled to false', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      c.enabled.value = true;
      c.functions.singleWhere((f) => f.name == 'OFF').function();
      expect(c.enabled.value, false);
    });

    test('Halve halves the frequency', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      c.functions.singleWhere((f) => f.name == 'Halve').function();
      expect(c.frequency.value, 500);
    });

    test('Double doubles the frequency', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      c.functions.singleWhere((f) => f.name == 'Double').function();
      expect(c.frequency.value, 2000);
    });

    test('duty can be set directly', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      c.duty.value = 0.75;
      expect(c.duty.value, 0.75);
    });

    test('frequency can be set directly', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      c.frequency.value = 440;
      expect(c.frequency.value, 440);
    });

    test('duty is clamped to 1.0 when set above 1', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      c.duty.value = 2.0;
      expect(c.duty.value, 1.0);
    });

    test('duty is clamped to 0.0 when set below 0', () {
      final c = DummyPwm(name: 'TestPwm', parentPath: []);
      c.duty.value = -0.5;
      expect(c.duty.value, 0.0);
    });
  });
}
