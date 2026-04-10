import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/audio_helper.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _correctCount = 0;
  int _totalCount = 10;
  int _packageId = 1;

  @override
  void initState() {
    super.initState();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _correctCount = args['correct_count'] ?? 0;
      _totalCount = args['total_count'] ?? 10;
      _packageId = args['package_id'] ?? 1;
    }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    AudioHelper.instance.playSuccess();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getStars() {
    if (_correctCount >= 10) return 3;
    if (_correctCount >= 7) return 2;
    if (_correctCount >= 3) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildResultContent(),
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent() {
    final stars = _getStars();
    final percentage = ((_correctCount / _totalCount) * 100).round();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: stars > 0 ? AppColors.primaryYellow : AppColors.secondaryBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (stars > 0 ? AppColors.primaryYellow : AppColors.secondaryBlue)
                    .withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            stars > 0 ? Icons.star : Icons.emoji_events,
            size: 80,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Icon(
              index < stars ? Icons.star : Icons.star_border,
              size: 40,
              color: index < stars ? AppColors.primaryYellow : const Color(0xFFE0E0E0),
            );
          }),
        ),
        const SizedBox(height: 20),
        Text(
          percentage >= 30 ? AppStrings.congratulation : '继续加油！',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textBrown,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '答对 $_correctCount / $_totalCount 题',
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF8D6E63),
          ),
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '+$correctCount 积分',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.successGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextLevel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                AppStrings.nextLevel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _retryLevel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: const BorderSide(color: AppColors.primaryYellow),
              ),
              child: const Text(
                AppStrings.retry,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryYellow,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '返回关卡',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8D6E63),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextLevel() {
    Navigator.pushReplacementNamed(context, '/quiz', arguments: {
      'package_id': _packageId + 1,
      'user_id': 1,
    });
  }

  void _retryLevel() {
    Navigator.pushReplacementNamed(context, '/quiz', arguments: {
      'package_id': _packageId,
      'user_id': 1,
    });
  }
}