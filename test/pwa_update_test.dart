import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/providers/pwa_update_provider.dart';

void main() {
  group('PwaUpdateProvider Tests', () {
    test('initial state has no update available and not updating', () {
      final provider = PwaUpdateProvider();
      expect(provider.isUpdateAvailable, isFalse);
      expect(provider.isUpdating, isFalse);
      provider.dispose();
    });

    test('applyUpdate sets isUpdating to true', () async {
      final provider = PwaUpdateProvider();
      expect(provider.isUpdating, isFalse);

      await provider.applyUpdate();
      expect(provider.isUpdating, isTrue);
      provider.dispose();
    });
  });
}
