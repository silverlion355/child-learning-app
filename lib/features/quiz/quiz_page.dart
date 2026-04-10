import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/audio_helper.dart';
import '../../data/database/database_helper.dart';
import '../../widgets/common/cartoon_button.dart';
import '../../widgets/backgrounds/tianzige_background.dart';
import '../../widgets/backgrounds/english_line_background.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _packageId = 1;
  int _userId = 1;
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _hasSubmitted = false;
  bool _isCorrect = false;
  List<int> _correctCount = [];
  int _totalAttempts = 0;

  final List<String> _correctPhrases = ['答对了，你真棒！', '太厉害了！', '答对了！', '真棒！'];
  final List<String> _wrongPhrases = ['再想想', '加油哦', '别灰心', '再试一次'];

  @override
  void initState() {
    super.initState();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _packageId = args['package_id'] ?? 1;
      _userId = args['user_id'] ?? 1;
    }
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await DatabaseHelper.instance.getLevels(_packageId);
    if (mounted) {
      setState(() {
        _questions = questions;
        _currentIndex = 0;
        _correctCount = [];
        _totalAttempts = 0;
      });
    }
  }

  String _getCategory() {
    if (_questions.isEmpty) return 'idiom';
    return _questions.first['type'].toString().split('_').first;
  }

  List<String> _getOptions() {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return [];
    final optionsJson = _questions[_currentIndex]['options'];
    if (optionsJson == null) return [];
    try {
      return List<String>.from(jsonDecode(optionsJson));
    } catch (e) {
      return [];
    }
  }

  void _selectAnswer(String answer) {
    if (_hasSubmitted) return;
    setState(() {
      _selectedAnswer = answer;
    });
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswer == null || _hasSubmitted) return;

    final correctAnswer = _questions[_currentIndex]['answer'];
    final isCorrect = _selectedAnswer == correctAnswer;

    setState(() {
      _hasSubmitted = true;
      _isCorrect = isCorrect;
      _totalAttempts++;
    });

    if (isCorrect) {
      _correctCount.add(_totalAttempts);
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) _nextQuestion();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _nextQuestion() {
    setState(() {
      _selectedAnswer = null;
      _hasSubmitted = false;
      _isCorrect = false;
      _totalAttempts = 0;
    });

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finishLevel();
    }
  }

  Future<void> _finishLevel() async {
    final correctCount = _correctCount.length;
    final score = correctCount * 10;
    
    await DatabaseHelper.instance.saveOrUpdateLearningRecord({
      'user_id': _userId,
      'level_id': _packageId,
      'completed_count': 1,
      'correct_count': correctCount,
      'total_attempts': _questions.length,
      'best_score': score,
      'total_time': 0,
      'is_favorite': 0,
      'last_attempt': DateTime.now().millisecondsSinceEpoch,
    });

    await DatabaseHelper.instance.updateLearningStats(_userId, score);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/result', arguments: {
        'correct_count': correctCount,
        'total_count': _questions.length,
        'package_id': _packageId,
      });
    }
  }

  String _getRandomPhrase(bool correct) {
    final phrases = correct ? _correctPhrases : _wrongPhrases;
    return phrases[DateTime.now().millisecond % phrases.length];
  }

  @override
  Widget build(BuildContext context) {
    final category = _getCategory();
    final isEnglishCategory = category == 'english';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textBrown),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${_questions.length}',
          style: const TextStyle(
            color: AppColors.textBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppColors.accentPink),
            onPressed: () {},
          ),
        ],
      ),
      body: isEnglishCategory
          ? EnglishLineBackground(child: _buildQuizContent())
          : TianZiGeBackground(child: _buildQuizContent()),
    );
  }

  Widget _buildQuizContent() {
    if (_questions.isEmpty || _currentIndex >= _questions.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final question = _questions[_currentIndex];
    final questionText = question['question'] ?? '';
    final explanation = question['explanation'] ?? '';
    final options = _getOptions();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildQuestionCard(questionText),
                  const SizedBox(height: 30),
                  _buildOptionsGrid(options),
                  if (_hasSubmitted && explanation.isNotEmpty)
                    _buildExplanation(explanation),
                ],
              ),
            ),
          ),
          if (_hasSubmitted)
            _buildFeedbackOverlay(),
          if (!_hasSubmitted)
            _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String questionText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: Text(
        questionText,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textBrown,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptionsGrid(List<String> options) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return _buildOptionButton(options[index], index);
      },
    );
  }

  Widget _buildOptionButton(String option, int index) {
    final isSelected = _selectedAnswer == option;
    final letters = ['A', 'B', 'C', 'D'];
    
    Color backgroundColor = Colors.white;
    Color borderColor = const Color(0xFFE0E0E0);
    Color textColor = AppColors.textBrown;

    if (_hasSubmitted) {
      final correctAnswer = _questions[_currentIndex]['answer'];
      if (option == correctAnswer) {
        backgroundColor = AppColors.successGreen;
        borderColor = AppColors.successGreen;
        textColor = Colors.white;
      } else if (isSelected && !_isCorrect) {
        backgroundColor = AppColors.errorRed;
        borderColor = AppColors.errorRed;
        textColor = Colors.white;
      }
    } else if (isSelected) {
      backgroundColor = AppColors.primaryYellow;
      borderColor = AppColors.primaryYellow;
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected || (_hasSubmitted && option == _questions[_currentIndex]['answer'])
                      ? Colors.white.withOpacity(0.3)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    letters[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation(String explanation) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📖 解释',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8D6E63),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textBrown,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackOverlay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: _isCorrect ? AppColors.successGreen : AppColors.errorRed,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.replay,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            _getRandomPhrase(_isCorrect),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: _selectedAnswer != null ? _submitAnswer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          disabledBackgroundColor: const Color(0xFFE0E0E0),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          AppStrings.checkAnswer,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出？'),
        content: const Text('退出后本次学习进度不会保存'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续学习'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}