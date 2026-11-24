import 'package:material_ui/material_ui.dart';

import '../../data/app_database.dart';
import 'exchange_rates.dart';

class ExchangeRatesPage extends StatefulWidget {
  const ExchangeRatesPage({required this.notesDao, super.key});

  final NotesDao notesDao;

  @override
  State<ExchangeRatesPage> createState() => _ExchangeRatesPageState();
}

class _ExchangeRatesPageState extends State<ExchangeRatesPage> {
  final _service = ExchangeRatesService();
  late Future<ExchangeRates> _rates;

  @override
  void initState() {
    super.initState();
    _rates = _loadRates();
  }

  Future<ExchangeRates> _loadRates() => _service.getMexicanPesoRates();

  void _reload() {
    setState(() => _rates = _loadRates());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasas y notas locales'),
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: 'Actualizar tasas',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<ExchangeRates>(
        future: _rates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = snapshot.error is RateApiException
                ? (snapshot.error! as RateApiException).message
                : 'No se pudieron cargar las tasas.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final rates = snapshot.data!;
          final codes = rates.rates.keys.toList()..sort();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '1 ${rates.base} · ${rates.date.toIso8601String().substring(0, 10)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final code in codes)
                ListTile(
                  dense: true,
                  title: Text(code),
                  trailing: Text(rates.rates[code]!.toStringAsFixed(4)),
                ),
              const Divider(),
              Text(
                'Notas guardadas con Drift',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'La base local contiene las tablas de notas y categorías. '
                'NotesDao.getByCategory filtra por categoría y ordena por fecha descendente.',
              ),
            ],
          );
        },
      ),
    );
  }
}
