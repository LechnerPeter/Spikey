import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spikey/components/component.dart';
import 'package:spikey/curated.dart';
import 'package:spikey/data.dart';
import 'package:spikey/logging.dart';
import 'package:spikey/widgets/popup.dart';
import 'widgets/component_view.dart';
import 'widgets/component_tree.dart';

void main() async {
  Logging.manual("Test Manual");
  Logging.info("Test Info");
  Logging.warning("Test Warning");
  Logging.error("Test Error");
  WidgetsFlutterBinding.ensureInitialized();
  Data.memory = await SharedPreferences.getInstance();
  runApp(const Spikey());
}

class Spikey extends HookWidget {
  const Spikey({super.key});

  final duration = Durations.medium1;
  final curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final main = Data.instance.main;
    final pc = usePageController();
    final page = useState<int>(0);
    return MaterialApp(
      title: 'Spikey',
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
              Curated(main: main),
              _Components(main: main),
            ],
          ),
        ),
      ),
    );
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
        Container(
          width: 200,
          height: MediaQuery.of(context).size.height,
          padding: .all(5),
          color: Colors.green.shade200,
          child: SingleChildScrollView(
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
