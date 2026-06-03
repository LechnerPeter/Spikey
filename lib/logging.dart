import 'dart:io';

import 'package:flutter/foundation.dart';

class Logging {
  static var consolePrint = true;
  static var buffer = <String>[];
  static final _dir = "${File(Platform.script.toFilePath()).parent.path}/logs";

  static Future<void> _addEntry(
    String info, [
    LoggingLevel level = .info,
  ]) async {
    final time = DateTime.now();
    final file = File("$_dir/log_${time.year}_${time.month}_${time.day}.ans");
    if (!Directory(_dir).existsSync()) Directory(_dir).createSync();
    if (!file.existsSync()) file.createSync();
    var timeStr = time.hour.toString().padLeft(2, '0');
    timeStr += ":${time.minute.toString().padLeft(2, '0')}";
    timeStr += ":${time.second.toString().padLeft(2, '0')}";
    timeStr += ".${time.millisecond.toString().padLeft(4, '0')}";
    final fullStr = "[$timeStr] ${levelToStr[level]} $info";
    file.writeAsStringSync("$fullStr\n", mode: .append);
    if (consolePrint && kDebugMode) debugPrint(fullStr);
  }

  static void manual(String info) async => await _addEntry(info, .manual);
  static void info(String info) async => await _addEntry(info, .info);
  static void warning(String info) async => await _addEntry(info, .warning);
  static void error(String info) async => await _addEntry(info, .error);
}

enum LoggingLevel { info, warning, error, manual }

const levelToStr = <LoggingLevel, String>{
  .manual: "[34m[MANUAL ][0m",
  .info: "[37m[INFO   ][0m",
  .warning: "[33m[WARNING][0m",
  .error: "[31m[ERROR  ][0m",
};
