import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/database/database_helper.dart';
import '../../widgets/common/cartoon_button.dart';
import '../../widgets/common/progress_bar.dart';

class LevelSelectPage extends StatefulWidget {
  const LevelSelectPage({super.key});

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends State<LevelSelectPage> {
  String _category = 'idiom';
  int _grade = 1;
  int _userId = 1;
  List<Map<String, dynamic>> _levelPackages = [];
  Map<int, Map<String, dynamic>> _records = {};

  @override
  void initState() {
    super.initState();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _category = args['category'] ?? 'idiom';
      _grade = args['grade'] ?? 1;
      _userId = args['userId'] ?? 1;
    }
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    final packages = await DatabaseHelper.instance.getLevelPackages(_category, _grade);
    if (mounted) {
      setState(() {
        _levelPackages = packages;
      });
    }
  }

  String _getCategoryTitle() {
    switch (_category) {
      case 'idiom':
        return '成语';
      case 'poem':
        return '诗词';
      case 'english':
        return '英语';
      default:
        return '';
    }
  }

  int _calculateProgress() {
    if (_levelPackages.isEmpty) return 0;
    int completed = 0;
    for (var pkg in _levelPackages) {
      if (_records.containsKey(pkg['id']) && (_records[pkg['id']]?['completed_count'] ?? 0) > 0) {
        completed++;
      }
    }
    return ((completed / _levelPackages.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_getCategoryTitle()}第$_grade关',
          style: const TextStyle(
            color: AppColors.textBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressHeader(),
          Expanded(child: _buildLevelGrid()),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '学习进度',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBrown,
                ),
              ),
              Text(
                '${_calculateProgress()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CartoonProgressBar(
            progress: _calculateProgress() / 100,
            height: 12,
            backgroundColor: const Color(0xFFE0E0E0),
            progressColor: AppColors.primaryYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: _levelPackages.length,
      itemBuilder: (context, index) {
        final package = _levelPackages[index];
        final record = _records[package['id']];
        final completedCount = record?['completed_count'] ?? 0;
        final isUnlocked = package['is_unlocked'] == 1 || index == 0 || _records.containsKey(_levelPackages[index - 1]['id']);
        
        return _buildLevelItem(package, index, completedCount, isUnlocked);
      },
    );
  }

  Widget _buildLevelItem(Map<String, dynamic> package, int index, int completedCount, bool isUnlocked) {
    final stars = completedCount > 0 ? ((completedCount / 10) * 3).round().clamp(0, 3) : 0;
    
    return GestureDetector(
      onTap: isUnlocked ? () => _startLevel(package['id']) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.primaryYellow : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.primaryYellow.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.white : const Color(0xFF9E9E9E),
              ),
            ),
            if (stars > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(stars, (i) {
                    return const Icon(Icons.star, size: 10, color: Colors.amber);
                  }),
                ),
              ),
            if (!isUnlocked)
              const Positioned(
                bottom: 4,
                child: Icon(Icons.lock, size: 12, color: Color(0xFF9E9E9E)),
              ),
          ],
        ),
      ),
    );
  }

  void _startLevel(int packageId) {
    Navigator.pushNamed(context, '/quiz', arguments: {
      'package_id': packageId,
      'user_id': _userId,
    });
  }
}