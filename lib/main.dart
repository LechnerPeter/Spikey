import 'dart:async';
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

final _locked = ValueNotifier<bool>(false);
void lockScreen() => _locked.value = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Data.memory = await SharedPreferences.getInstance();
  runApp(_LoggingInit());
}

class _LoggingInit extends HookWidget {
  const _LoggingInit();

  @override
  Widget build(BuildContext context) {
    final messengerKey = useMemoized(() => GlobalKey<ScaffoldMessengerState>());
    final ready = useState(false);

    useEffect(() {
      Logging.messengerKey = messengerKey;
      WidgetsBinding.instance.addPostFrameCallback((_) => ready.value = true);
      return null;
    }, []);

    if (!ready.value) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return Spikey(messengerKey: messengerKey);
  }
}

class Spikey extends HookWidget {
  const Spikey({super.key, required this.messengerKey});

  final duration = Durations.medium1;
  final curve = Curves.easeInOut;
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  @override
  Widget build(BuildContext context) {
    final main = Data.instance.main;
    final pc = usePageController();
    final page = useState<int>(0);
    final locked = useValueListenable(_locked);
    final timerRef = useRef<Timer?>(null);

    void restartTimer() {
      timerRef.value?.cancel();
      timerRef.value = Timer(const Duration(seconds: 15), lockScreen);
    }

    useEffect(() {
      restartTimer();
      return () => timerRef.value?.cancel();
    }, []);

    useEffect(() {
      if (!locked) restartTimer();
      return null;
    }, [locked]);

    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      title: 'Spikey',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      home: RotatedBox(
        quarterTurns: main.settings.rotation.value,
        child: Listener(
          onPointerDown: (_) => restartTimer(),
          child: Stack(
            children: [
              Scaffold(
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
                    SizedBox(width: 120, child: _BrightnessSlider()),
                    if (!locked)
                      ElevatedButton(
                        onPressed: lockScreen,
                        child: SizedBox(
                          height: 40,
                          child: Center(child: Icon(Icons.lock)),
                        ),
                      ),
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
                          child: Text(
                            page.value == 0 ? "Components" : "Display",
                          ),
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
              if (locked) _LockScreen(onUnlock: () => _locked.value = false),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrightnessSlider extends HookWidget {
  const _BrightnessSlider();

  static String? _backlightDir() {
    final dir = Directory('/sys/class/backlight');
    if (!dir.existsSync()) return null;
    final entries = dir.listSync();
    return entries.isEmpty ? null : entries.first.path;
  }

  @override
  Widget build(BuildContext context) {
    final dir = useMemoized(_backlightDir);
    final maxBrightness = useMemoized(() {
      if (dir == null) return 255.0;
      final f = File('$dir/max_brightness');
      return f.existsSync() ? double.parse(f.readAsStringSync().trim()) : 255.0;
    });
    final brightness = useState(128.0);

    useEffect(() {
      if (dir == null) return null;
      final f = File('$dir/brightness');
      if (f.existsSync()) {
        brightness.value = double.parse(f.readAsStringSync().trim());
      }
      return null;
    }, const []);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      child: Slider(
        value: brightness.value,
        min: (maxBrightness / 10).roundToDouble(),
        max: maxBrightness,
        onChanged: (v) {
          brightness.value = v;
          if (dir != null) {
            try {
              File('$dir/brightness').writeAsStringSync(v.round().toString());
            } catch (e) {
              Logging.error('Brightness write failed: $e');
            }
          }
        },
      ),
    );
  }
}

class _LockScreen extends HookWidget {
  const _LockScreen({required this.onUnlock});

  final VoidCallback onUnlock;

  static const _threshold = 150.0;

  @override
  Widget build(BuildContext context) {
    final offset = useState(0.0);
    final progress = offset.value / _threshold;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (d) =>
          offset.value = (offset.value + d.delta.dx).clamp(0.0, _threshold),
      onHorizontalDragEnd: (_) {
        if (offset.value >= _threshold) onUnlock();
        offset.value = 0;
      },
      child: Container(
        color: Colors.transparent,
        child: Align(
          alignment: .bottomCenter,
          child: Column(
            mainAxisAlignment: .end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(offset.value, -30),
                child: Icon(
                  Icons.lock,
                  size: 64,
                  color: Color.lerp(Colors.black, Colors.green, progress),
                ),
              ),
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
          child: SingleChildScrollView(
            child: Container(
              color: Colors.lightGreen.shade200,
              child: ComponentView(component: selected.value),
            ),
          ),
        ),
      ],
    );
  }
}
