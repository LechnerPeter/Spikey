import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spikey/components/generic/analog_pwm_connector.dart';
import 'package:spikey/components/generic/keepalive.dart';
import 'package:spikey/components/generic/switch.dart' as spikey;
import 'package:spikey/components/io/adc/adc_dummy.dart';
import 'package:spikey/components/io/gpio/io_dummy.dart';
import 'package:spikey/components/io/pwm/pwm_dummy.dart';
import 'package:spikey/data.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Data.memory = await SharedPreferences.getInstance();
  });

  group('Switch', () {
    test('has Input and Output in references', () {
      final input = DummyReadComponent(name: 'Input', parentPath: []);
      final output = DummyWriteComponent(name: 'Output', parentPath: []);
      final s = spikey.Switch(name: 'TestSwitch', parentPath: [], input: input, output: output);
      expect(s.references['Input'], input);
      expect(s.references['Output'], output);
    });

    test('output follows input state', () {
      final input = DummyReadComponent(name: 'Input', parentPath: []);
      final output = DummyWriteComponent(name: 'Output', parentPath: []);
      spikey.Switch(name: 'TestSwitch', parentPath: [], input: input, output: output);

      input.state.value = true;
      expect(output.state.value, true);

      input.state.value = false;
      expect(output.state.value, false);
    });
  });

  group('AnalogPwmConnector', () {
    test('enables PWM on construction', () {
      final adc = ADCDummy(name: 'ADC', parentPath: []);
      final pwm = DummyPwm(name: 'PWM', parentPath: []);
      AnalogPwmConnector(name: 'TestConnector', parentPath: [], adc: adc, pwm: pwm);
      expect(pwm.enabled.value, true);
    });

    test('syncs duty to adc.normalized on construction', () {
      final adc = ADCDummy(name: 'ADC', parentPath: []);
      final pwm = DummyPwm(name: 'PWM', parentPath: []);
      AnalogPwmConnector(name: 'TestConnector', parentPath: [], adc: adc, pwm: pwm);
      expect(pwm.duty.value, adc.normalized);
    });

    test('duty updates when adc state changes', () {
      final adc = ADCDummy(name: 'ADC', parentPath: []);
      final pwm = DummyPwm(name: 'PWM', parentPath: []);
      AnalogPwmConnector(name: 'TestConnector', parentPath: [], adc: adc, pwm: pwm);

      adc.state.value = 2048;
      expect(pwm.duty.value, adc.normalized);
    });

    test('has ADC and PWM in references', () {
      final adc = ADCDummy(name: 'ADC', parentPath: []);
      final pwm = DummyPwm(name: 'PWM', parentPath: []);
      final c = AnalogPwmConnector(name: 'TestConnector', parentPath: [], adc: adc, pwm: pwm);
      expect(c.references['ADC'], adc);
      expect(c.references['PWM'], pwm);
    });
  });

  group('Keepalive', () {
    test('has Output and Controll in references', () {
      fakeAsync((fake) {
        final output = DummyWriteComponent(name: 'Output', parentPath: []);
        final controll = DummyReadComponent(name: 'Controll', parentPath: []);
        final k = Keepalive(name: 'TestKeepalive', parentPath: [], output: output, controll: controll);
        expect(k.references['Output'], output);
        expect(k.references['Controll'], controll);
        fake.flushMicrotasks();
      });
    });

    test('sets output to true immediately on construction', () {
      fakeAsync((fake) {
        final output = DummyWriteComponent(name: 'Output', parentPath: []);
        final controll = DummyReadComponent(name: 'Controll', parentPath: []);
        Keepalive(name: 'TestKeepalive', parentPath: [], output: output, controll: controll);
        expect(output.state.value, true);
        fake.flushMicrotasks();
      });
    });

    test('output toggles every second', () {
      fakeAsync((fake) {
        final output = DummyWriteComponent(name: 'Output', parentPath: []);
        final controll = DummyReadComponent(name: 'Controll', parentPath: []);
        Keepalive(name: 'TestKeepalive', parentPath: [], output: output, controll: controll);

        expect(output.state.value, true);

        fake.elapse(const Duration(seconds: 1));
        expect(output.state.value, false);

        fake.elapse(const Duration(seconds: 1));
        expect(output.state.value, true);
      });
    });
  });
}
