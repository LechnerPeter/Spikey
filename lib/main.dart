import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/data.dart';
import 'package:thornstrike/logging.dart';
import 'package:thornstrike/widgets/popup.dart';
import 'widgets/component_view.dart';
import 'widgets/component_tree.dart';

void main() async {
  Logging.manual("Test Manual");
  Logging.info("Test Info");
  Logging.warning("Test Warning");
  Logging.error("Test Error");
  WidgetsFlutterBinding.ensureInitialized();
  /*
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('ThornStrike');
    setWindowFrame(const Rect.fromLTRB(0, 0, 800, 480 + 55));
  }
  */
  Data.memory = await SharedPreferences.getInstance();
  runApp(const ThornStrike());
}

class ThornStrike extends HookWidget {
  const ThornStrike({super.key});

  final duration = Durations.medium1;
  final curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final main = Data.instance.main;
    final pc = usePageController();
    final page = useState<int>(0);
    return MaterialApp(
      title: 'ThornStrike',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      home: RotatedBox(
        quarterTurns: main.settings.rotation.value,
        child: Scaffold(
          appBar: AppBar(
            leading: PopupButton(
              child: Image.asset("assets/spikey.png"),
              builder: (c) => GestureDetector(
                onTap: () => Navigator.pop(c),
                child: Image.asset("assets/spikey.png"),
              ),
            ),
            toolbarHeight: 30,
            backgroundColor: Colors.lightGreen,
            title: Text("Spikey", style: TextStyle(fontWeight: .w900)),
            actions: [
              ElevatedButton(
                onLongPress: () => exit(0),
                onPressed: () {
                  page.value = page.value == 0 ? 1 : 0;
                  if (page.value == 0) {
                    pc.animateToPage(0, duration: duration, curve: curve);
                  } else {
                    pc.animateToPage(1, duration: duration, curve: curve);
                  }
                },
                child: SizedBox(
                  width: 100,
                  height: 40,
                  child: Center(
                    child: Text(page.value == 0 ? "Components" : "Display"),
                  ),
                ),
              ),
            ],
          ),
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pc,
            children: [
              _Display(main: main),
              _Components(main: main),
            ],
          ),
        ),
      ),
    );
  }
}

class _Display extends HookWidget {
  const _Display({required this.main});

  final Component main;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(children: [for (var w in getAll(main)) w.builder(context)]),
    );
  }

  List<ComponentWidget> getAll(Component component) {
    final ret = <ComponentWidget>[];
    ret.addAll(component.widgets);
    for (var c in component.children) {
      ret.addAll(getAll(c));
    }
    return ret;
  }
}

class _Components extends HookWidget {
  const _Components({required this.main});

  final Component main;

  @override
  Widget build(BuildContext context) {
    final selected = useState<Component>(Data.instance.main);
    return Row(
      crossAxisAlignment: .start,
      children: [
        SingleChildScrollView(
          child: Container(
            width: 200,
            padding: .all(5),
            color: Colors.green.shade200,
            child: ComponentTree(component: main, selected: selected),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.lightGreen.shade200,
            child: ComponentView(component: selected.value),
          ),
        ),
      ],
    );
  }
}
