import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../data/database/database_helper.dart';
import '../../widgets/common/cartoon_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _currentUserId;
  String _currentCategory = 'idiom';
  int _currentGrade = 1;
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await DatabaseHelper.instance.getAllUsers();
    final stats = await DatabaseHelper.instance.getLearningStats(1);
    if (mounted) {
      setState(() {
        _users = users;
        _stats = stats;
        if (users.isNotEmpty && _currentUserId == null) {
          _currentUserId = users.first['id'];
        }
      });
    }
  }

  void _selectCategory(String category) {
    setState(() {
      _currentCategory = category;
    });
    Navigator.pushNamed(context, '/levels', arguments: {
      'category': category,
      'grade': _currentGrade,
      'userId': _currentUserId,
    });
  }

  void _selectGrade(int grade) {
    setState(() {
      _currentGrade = grade;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildGradeSelector(),
            const SizedBox(height: 20),
            Expanded(child: _buildCategoryGrid()),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showUserSwitchDialog(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryYellow,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryYellow.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.person, size: 30, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _users.isNotEmpty ? _users.first['nickname'] ?? '小朋友' : '小朋友',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBrown,
                  ),
                ),
                if (_stats != null)
                  Text(
                    '已学习 ${_stats!['continue_days']} 天',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8D6E63),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: AppColors.accentPink),
            onPressed: () => Navigator.pushNamed(context, '/collection'),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.textBrown),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeSelector() {
    final grades = List.generate(12, (i) => i + 1);
    final primaryGrades = [1, 2, 3, 4, 5, 6];
    final middleGrades = [7, 8, 9];
    final highGrades = [10, 11, 12];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildGradeGroup('小学', primaryGrades),
          const SizedBox(width: 16),
          _buildGradeGroup('初中', middleGrades),
          const SizedBox(width: 16),
          _buildGradeGroup('高中', highGrades),
        ],
      ),
    );
  }

  Widget _buildGradeGroup(String label, List<int> grades) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8D6E63),
          ),
        ),
        const SizedBox(width: 8),
        ...grades.map((g) => _buildGradeChip(g)),
      ],
    );
  }

  Widget _buildGradeChip(int grade) {
    final isSelected = _currentGrade == grade;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _selectGrade(grade),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryYellow : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? AppColors.primaryYellow : const Color(0xFFE0E0E0),
            ),
          ),
          child: Text(
            '$grade',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textBrown,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
        children: [
          _buildCategoryCard('idiom', '📚', AppColors.accentPink, '成语学习'),
          _buildCategoryCard('poem', '📖', AppColors.secondaryBlue, '诗词诵读'),
          _buildCategoryCard('english', '🔤', AppColors.primaryYellow, '英语单词'),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, String emoji, Color color, String title) {
    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '点击开始学习',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.favorite, '收藏', '/collection'),
          _buildNavItem(Icons.person, '我的', '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textBrown, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textBrown,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserSwitchDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '切换用户',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _users.map((user) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentUserId = user['id'];
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 30),
                        Text(
                          user['nickname'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showCreateUserDialog(),
              child: const Text('添加新用户'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateUserDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建新用户'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入昵称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final userId = await DatabaseHelper.instance.createUser(
                  controller.text,
                  _users.length + 1,
                );
                _loadUsers();
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}