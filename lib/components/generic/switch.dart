import 'package:spikey/components/component.dart';
import 'package:spikey/components/io/gpio/io.dart';
import 'package:spikey/components/parameter.dart';
import 'package:spikey/data.dart';

class Switch extends Component {
  Switch({
    required super.name,
    required super.parentPath,
    super.parameter,
    super.children,
    super.references,
    required this.input,
    required this.output,
  }) {
    input.state.addListener(() => output.state.value = input.state.value);
    references.addAll({"Input": input, "Output": output});
  }

  final IORead input;
  final IOWrite output;

  factory Switch.create({
    required String name,
    required List<String> parentPath,
    required Map json,
    List<Component> children = const [],
    List<Parameter> parameter = const [],
  }) {
    final input = Data.getComponent<IORead>(json["input"]);
    final output = Data.getComponent<IOWrite>(json["output"]);
    return Switch(
      name: name,
      parentPath: parentPath,
      children: children,
      parameter: parameter,
      input: input,
      output: output,
    );
  }
}
