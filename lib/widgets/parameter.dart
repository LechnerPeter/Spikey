import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:spikey/logging.dart';
import 'package:spikey/widgets/popup.dart';

import '../components/parameter.dart';

class ParameterWidget extends HookWidget {
  const ParameterWidget({super.key, required this.parameter});

  final Parameter<dynamic> parameter;

  @override
  Widget build(BuildContext context) {
    final edit = useValueListenable(parameter.userEditable);
    dynamic value = useValueListenable(parameter);
    return Container(
      color: Colors.lightGreen.shade300,
      height: 40,
      child: Row(
        mainAxisAlignment: .spaceAround,
        children: [
          Text(parameter.name),
          Text(parameter.runtimeType.toString()),
          Text(value.toString()),
          if (edit) ChangeParameter(parameter: parameter),
          Switch(
            value: useValueListenable(parameter.show),
            onChanged: (value) => parameter.show.value = value,
          ),
        ],
      ),
    );
  }
}

class ChangeParameter extends HookWidget {
  const ChangeParameter({super.key, required this.parameter});

  final Parameter<dynamic> parameter;

  @override
  Widget build(BuildContext context) {
    switch (parameter) {
      case Parameter<int> param:
        return _PopupNumber(parameter: param);
      case Parameter<double> param:
        return _PopupNumber(parameter: param);
      case Parameter<bool> flipme:
        return Switch(
          value: useValueListenable(flipme),
          onChanged: (bool value) => flipme.value = value,
        );
      default:
        Logging.error("Unknkown type ${parameter.runtimeType.toString()}");
        return Text("Unknown Type");
    }
  }
}

class _PopupNumber extends StatelessWidget {
  const _PopupNumber({required this.parameter});

  final Parameter<num> parameter;

  @override
  Widget build(BuildContext context) {
    return PopupButton<num>(
      child: Container(
        color: Colors.grey.shade200,
        width: 60,
        height: 30,
        child: Center(child: Text("Change")),
      ),
      builder: (context) => _Inner(initial: parameter.value.toString()),
      after: (value) {
        if (value == null) return;
        switch (parameter) {
          case Parameter<int> _:
            parameter.value = value.toInt();
          case Parameter<double> _:
            parameter.value = value.toDouble();
          default:
            Logging.error("Number Type not found");
        }
      },
    );
  }
}

class _Inner extends HookWidget {
  const _Inner({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final text = useState<String>(initial);
    return Center(
      child: Container(
        width: 200,
        height: 200,
        color: Colors.white,
        child: Padding(
          padding: .all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: .spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Align(
                        alignment: .centerRight,
                        child: Text(text.value),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => text.value = text.value.substring(
                        0,
                        text.value.length - 1,
                      ),
                      child: Text("<-"),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    _Button(text: text, char: "1"),
                    _Button(text: text, char: "2"),
                    _Button(text: text, char: "3"),
                  ],
                ),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    _Button(text: text, char: "4"),
                    _Button(text: text, char: "5"),
                    _Button(text: text, char: "6"),
                  ],
                ),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    _Button(text: text, char: "7"),
                    _Button(text: text, char: "8"),
                    _Button(text: text, char: "9"),
                  ],
                ),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    _Button(text: text, char: "."),
                    _Button(text: text, char: "0"),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, num.tryParse(text.value));
                      },
                      child: Text("OK"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.text, required this.char});

  final ValueNotifier<String> text;
  final String char;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => text.value = "${text.value}$char",
      child: Text(char),
    );
  }
}
