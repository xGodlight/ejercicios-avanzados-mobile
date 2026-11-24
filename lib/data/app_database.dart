import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  IntColumn get color => integer()();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get content => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();
}

@DriftAccessor(tables: [Notes, Categories])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Future<List<Category>> getCategories() => select(categories).get();

  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);

  Future<List<Note>> getByCategory(int categoryId) {
    return (select(notes)
          ..where((note) => note.categoryId.equals(categoryId))
          ..orderBy([(note) => OrderingTerm.desc(note.date)]))
        .get();
  }

  Stream<List<Note>> watchByCategory(int categoryId) {
    return (select(notes)
          ..where((note) => note.categoryId.equals(categoryId))
          ..orderBy([(note) => OrderingTerm.desc(note.date)]))
        .watch();
  }
}

@DriftDatabase(tables: [Categories, Notes], daos: [NotesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'notes.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (database) => database.execute('PRAGMA foreign_keys = ON;'),
    );
  });
}
