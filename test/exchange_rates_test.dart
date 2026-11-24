import 'package:ejercicios_avanzados_mobile/features/exchange_rates/exchange_rates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExchangeRates.fromJson', () {
    test('parses base, date, and numeric rates', () {
      final result = ExchangeRates.fromJson({
        'base': 'MXN',
        'date': '2026-11-24',
        'rates': {'USD': 0.058, 'JPY': 9},
      });

      expect(result.base, 'MXN');
      expect(result.date, DateTime(2026, 11, 24));
      expect(result.rates, {'USD': 0.058, 'JPY': 9.0});
    });

    test('rejects invalid rate values', () {
      expect(
        () => ExchangeRates.fromJson({
          'base': 'MXN',
          'date': '2026-11-24',
          'rates': {'USD': 'not-a-number'},
        }),
        throwsFormatException,
      );
    });
  });
}
