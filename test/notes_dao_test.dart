import 'package:drift/native.dart';
import 'package:ejercicios_avanzados_mobile/data/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('returns only the selected category, newest note first', () async {
    final categoryId = await database.notesDao.insertCategory(
      CategoriesCompanion.insert(name: 'Trabajo', color: 0xff336699),
    );
    final otherCategoryId = await database.notesDao.insertCategory(
      CategoriesCompanion.insert(name: 'Casa', color: 0xff669933),
    );

    await database.notesDao.insertNote(
      NotesCompanion.insert(
        title: 'Antigua',
        content: 'Primera nota',
        date: DateTime(2026, 1, 1),
        categoryId: categoryId,
      ),
    );
    await database.notesDao.insertNote(
      NotesCompanion.insert(
        title: 'Nueva',
        content: 'Última nota',
        date: DateTime(2026, 2, 1),
        categoryId: categoryId,
      ),
    );
    await database.notesDao.insertNote(
      NotesCompanion.insert(
        title: 'Otra categoría',
        content: 'No debe aparecer',
        date: DateTime(2026, 3, 1),
        categoryId: otherCategoryId,
      ),
    );

    final notes = await database.notesDao.getByCategory(categoryId);

    expect(notes.map((note) => note.title), ['Nueva', 'Antigua']);
  });
}
