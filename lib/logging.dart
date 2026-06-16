import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Logging {
  static var consolePrint = true;
  static var level = LoggingLevel.warning;
  static var buffer = <String>[];
  static final _dir = "${File(Platform.script.toFilePath()).parent.path}/logs";

  static GlobalKey<ScaffoldMessengerState>? messengerKey;

  static Future<void> _addEntry(
    String info,
    bool showSnackbar,
    LoggingLevel level,
  ) async {
    final time = DateTime.now();
    var timeStr = time.hour.toString().padLeft(2, '0');
    timeStr += ":${time.minute.toString().padLeft(2, '0')}";
    timeStr += ":${time.second.toString().padLeft(2, '0')}";
    timeStr += ".${time.millisecond.toString().padLeft(3, '0')}";
    final fullStr = "[$timeStr] ${levelToStr[level]} $info";
    if (level.index >= Logging.level.index) {
      final file = File("$_dir/log_${time.year}_${time.month}_${time.day}.ans");
      if (!Directory(_dir).existsSync()) Directory(_dir).createSync();
      if (!file.existsSync()) file.createSync();
      file.writeAsStringSync("$fullStr\n", mode: .append);
    }
    if (consolePrint && kDebugMode) debugPrint(fullStr);
    if (showSnackbar) _showSnackbar(info, level);
  }

  static void _showSnackbar(String message, LoggingLevel level) {
    final color = switch (level) {
      LoggingLevel.error => Colors.red,
      LoggingLevel.warning => Colors.orange,
      _ => null,
    };
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final messenger = messengerKey?.currentState;
      if (messenger == null) return;
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    });
  }

  static Future<void> manual(String info, {bool showSnackbar = false}) async =>
      await _addEntry(info, showSnackbar, .manual);
  static Future<void> info(String info, {bool showSnackbar = false}) async =>
      await _addEntry(info, showSnackbar, .info);
  static Future<void> warning(String info, {bool showSnackbar = true}) async =>
      await _addEntry(info, showSnackbar, .warning);
  static Future<void> error(String info, {bool showSnackbar = true}) async =>
      await _addEntry(info, showSnackbar, .error);
}

enum LoggingLevel { info, warning, error, manual }

const levelToStr = <LoggingLevel, String>{
  .manual: "[34m[MANUAL ][0m",
  .info: "[37m[INFO   ][0m",
  .warning: "[33m[WARNING][0m",
  .error: "[31m[ERROR  ][0m",
};
