import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spikey/components/component.dart';
import 'package:spikey/components/generic/analog_pwm_connector.dart';
import 'package:spikey/components/generic/keepalive.dart';
import 'package:spikey/components/generic/switch.dart' as spikey;
import 'package:spikey/components/io/adc/adc_dummy.dart';
import 'package:spikey/components/io/gpio/io_dummy.dart';
import 'package:spikey/components/io/pwm/pwm_dummy.dart';
import 'package:spikey/components/loader.dart';
import 'package:spikey/data.dart';

// Paths used in every typed-component test JSON
const _readPath = ['Main', 'TestRead'];
const _writePath = ['Main', 'TestWrite'];
const _adcPath = ['Main', 'TestADC'];
const _pwmPath = ['Main', 'TestPwm'];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DummyReadComponent testRead;
  late DummyWriteComponent testWrite;
  late ADCDummy testAdc;
  late DummyPwm testPwm;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Data.memory = await SharedPreferences.getInstance();

    // Seed the live component tree so Data.getComponent can resolve test paths.
    testRead = DummyReadComponent(name: 'TestRead', parentPath: ['Main']);
    testWrite = DummyWriteComponent(name: 'TestWrite', parentPath: ['Main']);
    testAdc = ADCDummy(name: 'TestADC', parentPath: ['Main']);
    testPwm = DummyPwm(name: 'TestPwm', parentPath: ['Main']);
    Data.instance.main.children.addAll([testRead, testWrite, testAdc, testPwm]);
  });

  tearDown(() {
    Data.instance.main.children.removeWhere(
      (c) => const {'TestRead', 'TestWrite', 'TestADC', 'TestPwm'}.contains(c.name),
    );
  });

  // ── Component (no type) ─────────────────────────────────────────────────────

  group('Component (no type)', () {
    test('returns Component for null type', () {
      expect(Loader.load({'name': 'Node'}), isA<Component>());
    });

    test('name is set correctly', () {
      expect(Loader.load({'name': 'MyNode'}).name, 'MyNode');
    });

    test('loads children recursively', () {
      final c = Loader.load({
        'name': 'Parent',
        'children': [
          {'name': 'Child'},
        ],
      });
      expect(c.children.length, 1);
      expect(c.children.first.name, 'Child');
    });

    test('loads int parameter', () {
      final c = Loader.load({
        'name': 'Node',
        'parameter': [
          {'name': 'Count', 'type': 'int', 'default': 5},
        ],
      });
      expect(c.parameter.length, 1);
      expect(c.parameter.first.name, 'Count');
      expect(c.parameter.first.value, 5);
    });

    test('resolves references from paths', () {
      final c = Loader.load({
        'name': 'Node',
        'references': {
          'MyInput': _readPath,
        },
      });
      expect(c.references['MyInput'], testRead);
    });

    test('unknown type falls back to Component', () {
      expect(Loader.load({'name': 'Node', 'type': 'bogus'}), isA<Component>());
    });
  });

  // ── Switch ──────────────────────────────────────────────────────────────────

  group('Switch', () {
    test('returns Switch', () {
      final c = Loader.load({
        'name': 'S',
        'type': 'switch',
        'input': _readPath,
        'output': _writePath,
      });
      expect(c, isA<spikey.Switch>());
    });

    test('wires input → output', () {
      Loader.load({
        'name': 'S',
        'type': 'switch',
        'input': _readPath,
        'output': _writePath,
      });
      testRead.state.value = true;
      expect(testWrite.state.value, true);
      testRead.state.value = false;
      expect(testWrite.state.value, false);
    });

    test('extra references from JSON are included', () {
      final c = Loader.load({
        'name': 'S',
        'type': 'switch',
        'input': _readPath,
        'output': _writePath,
        'references': {'Extra': _adcPath},
      });
      expect(c.references['Extra'], testAdc);
    });
  });

  // ── AnalogPwmConnector ──────────────────────────────────────────────────────

  group('AnalogPwmConnector', () {
    test('returns AnalogPwmConnector', () {
      final c = Loader.load({
        'name': 'C',
        'type': 'connector',
        'pwm': _pwmPath,
        'adc': _adcPath,
      });
      expect(c, isA<AnalogPwmConnector>());
    });

    test('enables PWM and syncs duty to ADC on construction', () {
      Loader.load({
        'name': 'C',
        'type': 'connector',
        'pwm': _pwmPath,
        'adc': _adcPath,
      });
      expect(testPwm.enabled.value, true);
      expect(testPwm.duty.value, testAdc.normalized);
    });

    test('duty tracks ADC state changes', () {
      Loader.load({
        'name': 'C',
        'type': 'connector',
        'pwm': _pwmPath,
        'adc': _adcPath,
      });
      testAdc.state.value = 2048;
      expect(testPwm.duty.value, testAdc.normalized);
    });
  });

  // ── Keepalive ───────────────────────────────────────────────────────────────

  group('Keepalive', () {
    test('returns Keepalive', () {
      fakeAsync((fake) {
        final c = Loader.load({
          'name': 'K',
          'type': 'keepalive',
          'output': _writePath,
          'controll': _readPath,
        });
        expect(c, isA<Keepalive>());
        fake.flushMicrotasks();
      });
    });

    test('output toggles every second', () {
      fakeAsync((fake) {
        Loader.load({
          'name': 'K',
          'type': 'keepalive',
          'output': _writePath,
          'controll': _readPath,
        });
        expect(testWrite.state.value, true);
        fake.elapse(const Duration(seconds: 1));
        expect(testWrite.state.value, false);
        fake.elapse(const Duration(seconds: 1));
        expect(testWrite.state.value, true);
      });
    });
  });

  // ── Loader.parameter() ──────────────────────────────────────────────────────

  group('Loader.parameter()', () {
    test('parses int parameter', () {
      final p = Loader.parameter({'name': 'X', 'type': 'int', 'default': 10}, []);
      expect(p.value, 10);
      expect(p.name, 'X');
    });

    test('throws for unknown parameter type', () {
      expect(
        () => Loader.parameter({'name': 'X', 'type': 'float', 'default': 1.0}, []),
        throwsException,
      );
    });
  });
}
