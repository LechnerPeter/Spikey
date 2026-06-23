import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spikey/components/io/adc/adc_dummy.dart';
import 'package:spikey/data.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Data.memory = await SharedPreferences.getInstance();
  });

  group('ADCDummy', () {
    test('initial state is 0', () {
      final c = ADCDummy(name: 'TestADC', parentPath: []);
      expect(c.state.value, 0);
    });

    test('isDummy is true', () {
      final c = ADCDummy(name: 'TestADC', parentPath: []);
      expect(c.isDummy, true);
    });

    test('min is 0, max is 4095', () {
      final c = ADCDummy(name: 'TestADC', parentPath: []);
      expect(c.min, 0);
      expect(c.max, 4095);
    });

    test('state is in parameter list', () {
      final c = ADCDummy(name: 'TestADC', parentPath: []);
      expect(c.parameter.contains(c.state), true);
    });

    test('has all expected functions', () {
      final c = ADCDummy(name: 'TestADC', parentPath: []);
      final names = c.functions.map((f) => f.name).toList();
      expect(names, containsAll(['Read', 'Start Loop', 'Stop Loop']));
    });

    test('has State widget', () {
      final c = ADCDummy(name: 'TestADC', parentPath: []);
      expect(c.widgets.any((w) => w.name == 'State'), true);
    });

    test('normalized is 0.0 when state is 0', () {
      final c = ADCDummy(name: 'TestADC', parentPath: []);
      expect(c.normalized, 0.0);
    });

    test('normalized reflects state value', () {
      final c = ADCDummy(name: 'TestADC', parentPath: []);
      c.state.value = 4095;
      expect(c.normalized, closeTo(1.0, 0.001));
    });

    test('Start Loop increments state immediately', () {
      fakeAsync((fake) {
        final c = ADCDummy(name: 'TestADC', parentPath: []);
        c.functions.singleWhere((f) => f.name == 'Start Loop').function();
        expect(c.state.value, 1);
      });
    });

    test('Start Loop keeps incrementing over time', () {
      fakeAsync((fake) {
        final c = ADCDummy(name: 'TestADC', parentPath: []);
        c.functions.singleWhere((f) => f.name == 'Start Loop').function();
        fake.elapse(const Duration(milliseconds: 5));
        expect(c.state.value, greaterThan(1));
      });
    });

    test('Stop Loop halts increments', () {
      fakeAsync((fake) {
        final c = ADCDummy(name: 'TestADC', parentPath: []);
        c.functions.singleWhere((f) => f.name == 'Start Loop').function();
        fake.elapse(const Duration(milliseconds: 5));

        c.functions.singleWhere((f) => f.name == 'Stop Loop').function();
        final stateAtStop = c.state.value;
        fake.elapse(const Duration(milliseconds: 100));
        expect(c.state.value, stateAtStop);
      });
    });

    test('state wraps around at 4095', () {
      fakeAsync((fake) {
        final c = ADCDummy(name: 'TestADC', parentPath: []);
        c.state.value = 4094;
        c.functions.singleWhere((f) => f.name == 'Start Loop').function();
        expect(c.state.value, 0); // (4094 + 1) % 4095 == 0
      });
    });
  });
}
