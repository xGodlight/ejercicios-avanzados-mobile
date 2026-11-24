import 'package:material_ui/material_ui.dart';

import 'data/app_database.dart';
import 'features/exchange_rates/exchange_rates_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExercisesApp());
}

class ExercisesApp extends StatefulWidget {
  const ExercisesApp({super.key});

  @override
  State<ExercisesApp> createState() => _ExercisesAppState();
}

class _ExercisesAppState extends State<ExercisesApp> {
  final _database = AppDatabase();

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ejercicios avanzados',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: ExchangeRatesPage(notesDao: _database.notesDao),
    );
  }
}
