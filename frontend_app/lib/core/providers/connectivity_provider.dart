import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Streams [true] when online, [false] when offline.
/// Uses a periodic DNS lookup — no extra package required.
final connectivityProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>();

  Future<void> check() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      controller.add(result.isNotEmpty && result.first.rawAddress.isNotEmpty);
    } catch (_) {
      controller.add(false);
    }
  }

  // Initial check
  check();

  // Periodic check every 5 seconds
  final timer = Timer.periodic(const Duration(seconds: 5), (_) => check());

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
