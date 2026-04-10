import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/strings.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._();

  Future<void> initDatabase() async {
    await database;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('studygame.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nickname TEXT NOT NULL,
        avatar_id INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        last_login INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE level_packages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        grade INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        level_count INTEGER NOT NULL DEFAULT 10,
        unlock_condition TEXT,
        is_unlocked INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE levels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        package_id INTEGER NOT NULL,
        level_index INTEGER NOT NULL,
        type TEXT NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        options TEXT,
        explanation TEXT,
        extra_info TEXT,
        score INTEGER NOT NULL DEFAULT 10,
        FOREIGN KEY (package_id) REFERENCES level_packages(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE learning_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        level_id INTEGER NOT NULL,
        completed_count INTEGER NOT NULL DEFAULT 0,
        correct_count INTEGER NOT NULL DEFAULT 0,
        total_attempts INTEGER NOT NULL DEFAULT 0,
        best_score INTEGER NOT NULL DEFAULT 0,
        total_time INTEGER NOT NULL DEFAULT 0,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        last_attempt INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (level_id) REFERENCES levels(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE learning_stats (
        user_id INTEGER PRIMARY KEY,
        total_score INTEGER NOT NULL DEFAULT 0,
        continue_days INTEGER NOT NULL DEFAULT 0,
        last_learning_date INTEGER,
        category_stats TEXT
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final defaultUser = await db.insert('users', {
      'nickname': '小朋友',
      'avatar_id': 1,
      'created_at': now,
      'last_login': now,
    });

    await db.insert('learning_stats', {
      'user_id': defaultUser,
      'total_score': 0,
      'continue_days': 0,
      'last_learning_date': null,
      'category_stats': '{"idiom":0,"poem":0,"english":0}',
    });

    final categories = ['idiom', 'poem', 'english'];
    final grades = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    final categoryNames = {
      'idiom': '成语',
      'poem': '诗词', 
      'english': '英语',
    };
    final categoryDescs = {
      'idiom': '学习常用成语',
      'poem': '诵读经典诗词',
      'english': '掌握英语单词',
    };

    for (final category in categories) {
      for (final grade in grades) {
        final packageId = await db.insert('level_packages', {
          'category': category,
          'grade': grade,
          'name': '${categoryNames[category]}第${grade}关',
          'description': categoryDescs[category],
          'level_count': 10,
          'is_unlocked': (grade == 1 && category == 'idiom') || (category != 'idiom' && grade == 1) ? 1 : 0,
        });

        for (int i = 1; i <= 10; i++) {
          await db.insert('levels', {
            'package_id': packageId,
            'level_index': i,
            'type': _getQuestionType(category, i),
            'question': _generateSampleQuestion(category, grade, i),
            'answer': _generateSampleAnswer(category, grade, i),
            'options': _generateSampleOptions(category, grade, i),
            'explanation': _generateSampleExplanation(category, grade, i),
            'extra_info': _generateExtraInfo(category, grade, i),
            'score': 10,
          });
        }
      }
    }
  }

  String _getQuestionType(String category, int levelIndex) {
    if (category == 'idiom') return 'idiom_fill';
    if (category == 'poem') {
      final types = ['poem_fill_word', 'poem_fill_char', 'poem_author', 'poem_title'];
      return types[levelIndex % 4];
    }
    final types = ['word_choice', 'chinese_choice', 'image_choice'];
    return types[levelIndex % 3];
  }

  String _generateSampleQuestion(String category, int grade, int levelIndex) {
    if (category == 'idiom') {
      final idioms = ['画蛇添足', '井底之蛙', '守株待兔', '刻舟求剑', '亡羊补牢', '掩耳盗铃', '滥竽充数', '胸有成竹', '画龙点睛', '叶公好龙'];
      final idx = (grade - 1) * 2 + (levelIndex - 1) % 2;
      final idiom = idioms[idx % idioms.length];
      final blankIdx = levelIndex % idiom.length;
      return '成语"$idiom"中，第${blankIdx + 1}个字应该填什么？';
    }
    if (category == 'poem') {
      return '《春晓》"春眠不觉晓，____闻啼鸟"应该填什么？';
    }
    return '请选择 "apple" 的中文意思';
  }

  String _generateSampleAnswer(String category, int grade, int levelIndex) {
    if (category == 'idiom') {
      final answers = ['足', '蛙', '株', '舟', '羊', '耳', '竽', '竹', '睛', '龙'];
      return answers[(grade - 1) * 2 + (levelIndex - 1) % 2];
    }
    if (category == 'poem') return '处处';
    return '苹果';
  }

  String _generateSampleOptions(String category, int grade, int levelIndex) {
    if (category == 'idiom') {
      final options = [
        '["足","头","尾","手"]',
        '["蛙","鱼","虾","龟"]',
        '["株","树","木","草"]',
        '["求","找","寻","等"]',
        '["羊","牛","马","猪"]',
        '["耳","眼","鼻","口"]',
        '["竽","竿","笛","箫"]',
        '["竹","木","草","花"]',
        '["睛","眼","目","角"]',
        '["龙","凤","龟","麟"]',
      ];
      return options[(grade - 1) * 2 + (levelIndex - 1) % 2];
    }
    if (category == 'poem') return '["处处","纷纷","深深","寥寥"]';
    return '["香蕉","苹果","橙子","葡萄"]';
  }

  String _generateSampleExplanation(String category, int grade, int levelIndex) {
    if (category == 'idiom') {
      final explanations = [
        '画蛇添足：比喻做多余的事有害无益。',
        '井底之蛙：比喻眼光狭小、见识浅薄的人。',
        '守株待兔：���喻不主动努力而侥幸得到成功。',
        '刻舟求剑：比喻拘泥成法，不根据实际处理。',
        '亡羊补牢：比喻出了问题后及时想办法补救。',
        '掩耳盗铃：比喻自己欺骗自己。',
        '滥竽充数：比喻没有真才实学的人混在里面。',
        '胸有成竹：比喻处理事情很有把握。',
        '画龙点睛：比喻说话或写文章在关键处点明要点。',
        '叶公好龙：比喻口头上说爱好，实际上害怕。',
      ];
      return explanations[(grade - 1) * 2 + (levelIndex - 1) % 2];
    }
    if (category == 'poem') return '《春晓》作者是唐代诗人孟浩然。';
    return 'apple：苹果，一种常见的水果。';
  }

  String _generateExtraInfo(String category, int grade, int levelIndex) {
    if (category == 'idiom') {
      return '{"origin":"《战国策》","synonym":"多此一举","antonym":"恰如其分"}';
    }
    if (category == 'poem') {
      return '{"author":"孟浩然","dynasty":"唐","type":"五言绝句"}';
    }
    return '{"phonetic":"/ˈæpəl/","example":"I eat an apple every day."}';
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'last_login DESC');
  }

  Future<int> createUser(String nickname, int avatarId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final userId = await db.insert('users', {
      'nickname': nickname,
      'avatar_id': avatarId,
      'created_at': now,
      'last_login': now,
    });
    await db.insert('learning_stats', {
      'user_id': userId,
      'total_score': 0,
      'continue_days': 0,
      'last_learning_date': null,
      'category_stats': '{"idiom":0,"poem":0,"english":0}',
    });
    return userId;
  }

  Future<void> updateLastLogin(int userId) async {
    final db = await database;
    await db.update(
      'users',
      {'last_login': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getLevelPackages(String category, int grade) async {
    final db = await database;
    return await db.query(
      'level_packages',
      where: 'category = ? AND grade = ?',
      whereArgs: [category, grade],
      orderBy: 'id ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getLevels(int packageId) async {
    final db = await database;
    return await db.query(
      'levels',
      where: 'package_id = ?',
      whereArgs: [packageId],
      orderBy: 'level_index ASC',
    );
  }

  Future<Map<String, dynamic>?> getLearningRecord(int userId, int levelId) async {
    final db = await database;
    final result = await db.query(
      'learning_records',
      where: 'user_id = ? AND level_id = ?',
      whereArgs: [userId, levelId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> saveOrUpdateLearningRecord(Map<String, dynamic> record) async {
    final db = await database;
    final existing = await getLearningRecord(record['user_id'], record['level_id']);
    if (existing != null) {
      await db.update(
        'learning_records',
        record,
        where: 'user_id = ? AND level_id = ?',
        whereArgs: [record['user_id'], record['level_id']],
      );
    } else {
      await db.insert('learning_records', record);
    }
  }

  Future<Map<String, dynamic>?> getLearningStats(int userId) async {
    final db = await database;
    final result = await db.query(
      'learning_stats',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateLearningStats(int userId, int scoreIncrement) async {
    final db = await database;
    final stats = await getLearningStats(userId);
    if (stats != null) {
      final newScore = (stats['total_score'] as int) + scoreIncrement;
      final today = DateTime.now().millisecondsSinceEpoch;
      final lastDate = stats['last_learning_date'] as int?;
      int continueDays = stats['continue_days'] as int;
      
      if (lastDate != null) {
        final lastDateTime = DateTime.fromMillisecondsSinceEpoch(lastDate);
        final todayDateTime = DateTime.fromMillisecondsSinceEpoch(today);
        if (lastDateTime.day != todayDateTime.day) {
          if (todayDateTime.difference(lastDateTime).inDays == 1) {
            continueDays++;
          } else {
            continueDays = 1;
          }
        }
      } else {
        continueDays = 1;
      }

      await db.update(
        'learning_stats',
        {
          'total_score': newScore,
          'continue_days': continueDays,
          'last_learning_date': today,
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}