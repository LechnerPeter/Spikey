import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/components/io/gpio/io.dart';

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
    references.addAll([input, output]);
  }

  final IOReadComponent input;
  final IOWriteComponent output;
}
