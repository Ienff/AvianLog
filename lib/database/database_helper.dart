import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // 定义数据库版本号
  static const int _databaseVersion = 2; // 从 1 升级到 2

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
      version: _databaseVersion, // 使用新的数据库版本号
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // 添加 onUpgrade 方法
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sample_points(
        id INTEGER PRIMARY KEY, -- 移除 AUTOINCREMENT
        time TEXT,
        coordinates TEXT,
        birdSpecies TEXT,
        gender TEXT,
        quantity INTEGER,
        habitatType TEXT,
        distanceToLine INTEGER,
        status TEXT,
        remarks TEXT,
        imagePath TEXT
      )
    ''');
  }

  // 数据库升级逻辑
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 如果旧版本小于 2，添加 imagePath 列
      await db.execute('ALTER TABLE sample_points ADD COLUMN imagePath TEXT');
    }
  }

  // 插入样点数据
  Future<int> insertSamplePoint(Map<String, dynamic> samplePoint) async {
    final db = await database;

    // 查询当前最大的 id
    final result = await db.rawQuery('SELECT MAX(id) as maxId FROM sample_points');
    final maxId = result.first['maxId'] as int?;

    // 计算下一个 id
    final nextId = (maxId ?? 0) + 1;

    // 插入数据
    samplePoint['id'] = nextId;
    return await db.insert('sample_points', samplePoint);
  }

  // 查询所有样点数据
  Future<List<Map<String, dynamic>>> getSamplePoints() async {
    final db = await database;
    return await db.query('sample_points');
  }

  // 删除样点数据
  Future<void> deleteSamplePoint(int id) async {
    final db = await database;
    await db.delete('sample_points', where: 'id = ?', whereArgs: [id]);
  }
}