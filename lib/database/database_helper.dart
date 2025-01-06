import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sample_points.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sample_points(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT,
        coordinates TEXT,
        birdSpecies TEXT,
        gender TEXT,
        quantity INTEGER,
        habitatType TEXT,
        distanceToLine INTEGER,
        status TEXT,
        remarks TEXT
      )
    ''');
  }

  // 插入样点数据
  Future<int> insertSamplePoint(Map<String, dynamic> samplePoint) async {
    final db = await database;
    return await db.insert('sample_points', samplePoint);
  }

  // 查询所有样点数据
  Future<List<Map<String, dynamic>>> getSamplePoints() async {
    final db = await database;
    return await db.query('sample_points');
  }
}