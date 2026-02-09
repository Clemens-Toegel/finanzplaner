import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

const _outputSubdirDefine = String.fromEnvironment('SCREENSHOT_OUTPUT_SUBDIR');
const _baseDirDefine = String.fromEnvironment('SCREENSHOT_BASE_DIR');
const _platformDefine = String.fromEnvironment('SCREENSHOT_PLATFORM');

String _envOrDefine(String envKey, String defineValue) {
  final envValue = (Platform.environment[envKey] ?? '').trim();
  return envValue.isNotEmpty ? envValue : defineValue.trim();
}

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, imageBytes, [args]) async {
      final platformDir = _envOrDefine('SCREENSHOT_PLATFORM', _platformDefine).isNotEmpty
          ? _envOrDefine('SCREENSHOT_PLATFORM', _platformDefine)
          : (Platform.isIOS ? 'ios' : 'android');

      final baseDirOverride = _envOrDefine('SCREENSHOT_BASE_DIR', _baseDirDefine);
      final outputSubdir = _envOrDefine('SCREENSHOT_OUTPUT_SUBDIR', _outputSubdirDefine);

      final baseDir = baseDirOverride.isEmpty
          ? 'screenshots/app_store/$platformDir'
          : baseDirOverride;

      final outputDir = outputSubdir.isEmpty
          ? Directory(baseDir)
          : Directory('$baseDir/$outputSubdir');
      await outputDir.create(recursive: true);

      final file = File('${outputDir.path}/$name.png');
      await file.writeAsBytes(imageBytes);
      return true;
    },
  );
}
