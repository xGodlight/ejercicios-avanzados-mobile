import 'package:dio/dio.dart';
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

  test('maps timeout, 404, and 5xx responses to clear failures', () async {
    expect(
      await failureFor(DioExceptionType.receiveTimeout),
      RateFailure.timeout,
    );
    expect(
      await failureFor(DioExceptionType.badResponse, statusCode: 404),
      RateFailure.notFound,
    );
    expect(
      await failureFor(DioExceptionType.badResponse, statusCode: 500),
      RateFailure.server,
    );
  });
}

Future<RateFailure> failureFor(
  DioExceptionType type, {
  int? statusCode,
}) async {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final response = statusCode == null
            ? null
            : Response(requestOptions: options, statusCode: statusCode);
        handler.reject(
          DioException(
            requestOptions: options,
            response: response,
            type: type,
          ),
        );
      },
    ),
  );

  try {
    await ExchangeRatesService(dio: dio).getMexicanPesoRates();
    fail('Expected a mapped API error.');
  } on RateApiException catch (error) {
    return error.failure;
  }
}
