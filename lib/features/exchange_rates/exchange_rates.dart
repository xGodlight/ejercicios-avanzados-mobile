import 'package:dio/dio.dart';

class ExchangeRates {
  const ExchangeRates({
    required this.base,
    required this.date,
    required this.rates,
  });

  final String base;
  final DateTime date;
  final Map<String, double> rates;

  factory ExchangeRates.fromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('La respuesta no es un objeto JSON.');
    }

    final base = json['base'];
    final dateValue = json['date'];
    final rawRates = json['rates'];
    if (base is! String || dateValue is! String || rawRates is! Map) {
      throw const FormatException('La respuesta no contiene base, fecha y tasas.');
    }

    final date = DateTime.tryParse(dateValue);
    if (date == null) {
      throw const FormatException('La fecha de las tasas no es válida.');
    }

    final rates = <String, double>{};
    for (final entry in rawRates.entries) {
      final code = entry.key;
      final value = entry.value;
      if (code is! String || value is! num || !value.isFinite) {
        throw const FormatException('La lista de tasas contiene datos inválidos.');
      }
      rates[code] = value.toDouble();
    }

    if (rates.isEmpty) {
      throw const FormatException('La respuesta no contiene tasas.');
    }
    return ExchangeRates(base: base, date: date, rates: rates);
  }
}

enum RateFailure { timeout, notFound, server, network, http, invalidResponse }

class RateApiException implements Exception {
  const RateApiException(this.failure, {this.statusCode});

  final RateFailure failure;
  final int? statusCode;

  String get message => switch (failure) {
        RateFailure.timeout => 'La consulta agotó el tiempo de espera.',
        RateFailure.notFound => 'No se encontró el recurso solicitado (404).',
        RateFailure.server => 'El servidor de tasas devolvió un error.',
        RateFailure.network => 'No se pudo conectar. Verifica tu conexión.',
        RateFailure.http => 'La solicitud falló (HTTP $statusCode).',
        RateFailure.invalidResponse => 'El servidor devolvió datos no válidos.',
      };

  @override
  String toString() => message;
}

class ExchangeRatesService {
  ExchangeRatesService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.exchangerate-api.com/v4',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio _dio;

  Future<ExchangeRates> getMexicanPesoRates() async {
    try {
      final response = await _dio.get<Object?>('/latest/MXN');
      return ExchangeRates.fromJson(response.data);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final failure = switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          RateFailure.timeout,
        DioExceptionType.connectionError => RateFailure.network,
        _ when statusCode == 404 => RateFailure.notFound,
        _ when statusCode != null && statusCode >= 500 => RateFailure.server,
        _ when statusCode != null => RateFailure.http,
        _ => RateFailure.network,
      };
      throw RateApiException(failure, statusCode: statusCode);
    } on FormatException {
      throw const RateApiException(RateFailure.invalidResponse);
    }
  }
}
