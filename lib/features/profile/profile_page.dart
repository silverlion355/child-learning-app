import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/database/database_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await DatabaseHelper.instance.getLearningStats(1);
    final users = await DatabaseHelper.instance.getUser(1);
    if (mounted) {
      setState(() {
        _stats = stats;
        _user = users;
      });
    }
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
        title: const Text(
          '个人中心',
          style: TextStyle(
            color: AppColors.textBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildUserInfo(),
            const SizedBox(height: 30),
            _buildStats(),
            const SizedBox(height: 30),
            _buildSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user?['nickname'] ?? '小朋友',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBrown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '加入于 ${DateTime.now().year}年',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textBrown),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '学习统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBrown,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem(
                Icons.local_fire_department,
                AppColors.accentPink,
                '${_stats?['continue_days'] ?? 0}',
                '连续学习',
              ),
              _buildStatItem(
                Icons.star,
                AppColors.primaryYellow,
                '${_stats?['total_score'] ?? 0}',
                '总积分',
              ),
              _buildStatItem(
                Icons.check_circle,
                AppColors.successGreen,
                '0',
                '完成关卡',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textBrown,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8D6E63),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBrown,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(Icons.volume_up, '音效', true),
          _buildSettingItem(Icons.music_note, '背景音乐', false),
          _buildSettingItem(Icons.info_outline, '关于我们', () {}),
          _buildSettingItem(Icons.help_outline, '帮助', () {}),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, dynamic toggleOrAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.textBrown),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textBrown,
              ),
            ),
          ),
          if (toggleOrAction is bool)
            Switch(
              value: toggleOrAction,
              onChanged: (value) {},
              activeColor: AppColors.primaryYellow,
            )
          else
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 18),
              onPressed: toggleOrAction is Function ? toggleOrAction : null,
            ),
        ],
      ),
    );
  }
}