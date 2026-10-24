import 'package:community/core/network/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiConfig.resolveBaseUrl', () {
    test('dart-define override wins in every mode', () {
      expect(
        ApiConfig.resolveBaseUrl(
          definedBaseUrl: 'https://staging.example.com/',
          isRelease: true,
          isAndroid: true,
        ),
        'https://staging.example.com',
      );
      expect(
        ApiConfig.resolveBaseUrl(
          definedBaseUrl: 'http://192.168.1.10:5162',
          isRelease: false,
          isAndroid: false,
        ),
        'http://192.168.1.10:5162',
      );
    });

    test('release without override uses production HTTPS host', () {
      expect(
        ApiConfig.resolveBaseUrl(
          definedBaseUrl: '',
          isRelease: true,
          isAndroid: true,
        ),
        ApiConfig.productionBaseUrl,
      );
      expect(
        ApiConfig.resolveBaseUrl(
          definedBaseUrl: '   ',
          isRelease: true,
          isAndroid: false,
        ),
        'https://usama498.bsite.net',
      );
    });

    test('release never falls back to localhost or emulator loopback', () {
      final url = ApiConfig.resolveBaseUrl(
        definedBaseUrl: '',
        isRelease: true,
        isAndroid: true,
      );
      expect(url.contains('localhost'), isFalse);
      expect(url.contains('127.0.0.1'), isFalse);
      expect(url.contains('10.0.2.2'), isFalse);
      expect(url.startsWith('https://'), isTrue);
    });

    test('debug Android uses emulator loopback', () {
      expect(
        ApiConfig.resolveBaseUrl(
          definedBaseUrl: '',
          isRelease: false,
          isAndroid: true,
        ),
        ApiConfig.androidEmulatorBaseUrl,
      );
    });

    test('debug non-Android uses localhost', () {
      expect(
        ApiConfig.resolveBaseUrl(
          definedBaseUrl: '',
          isRelease: false,
          isAndroid: false,
        ),
        ApiConfig.localDevBaseUrl,
      );
    });
  });
}
