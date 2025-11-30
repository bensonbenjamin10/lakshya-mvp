import 'package:flutter/material.dart';
import 'package:lakshya_mvp/models/course_module.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Optimized Quiz widget with clean Material Design 3 aesthetics
/// 
/// Features:
/// - Step indicator instead of progress bar
/// - Card-based question display
/// - Animated transitions
/// - Celebratory results view
class QuizWidget extends StatefulWidget {
  final CourseModule module;
  final String enrollmentId;
  final StudentProgress? progress;
  final VoidCallback onQuizComplete;

  const QuizWidget({
    super.key,
    required this.module,
    required this.enrollmentId,
    this.progress,
    required this.onQuizComplete,
  });

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  final Map<int, int> _answers = {}; // questionIndex -> optionIndex
  bool _isSubmitted = false;
  int _score = 0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sample quiz questions (in production, fetch from module.contentBody or API)
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the primary purpose of financial accounting?',
      'options': [
        'To help managers make decisions',
        'To provide information to external users',
        'To calculate taxes',
        'To manage inventory',
      ],
      'correct': 1,
    },
    {
      'question': 'Which financial statement shows assets, liabilities, and equity?',
      'options': [
        'Income Statement',
        'Balance Sheet',
        'Cash Flow Statement',
        'Statement of Retained Earnings',
      ],
      'correct': 1,
    },
    {
      'question': 'What does GAAP stand for?',
      'options': [
        'Generally Accepted Accounting Principles',
        'General Accounting and Auditing Procedures',
        'Government Accounting and Auditing Practices',
        'Global Accounting and Auditing Principles',
      ],
      'correct': 0,
    },
    {
      'question': 'Which accounting method records revenue when earned?',
      'options': [
        'Cash basis',
        'Accrual basis',
        'Modified cash basis',
        'Hybrid basis',
      ],
      'correct': 1,
    },
    {
      'question': 'What is the accounting equation?',
      'options': [
        'Assets = Liabilities + Equity',
        'Revenue = Expenses + Profit',
        'Assets = Revenue - Expenses',
        'Equity = Assets - Revenue',
      ],
      'correct': 0,
    },
  ];

  int get _totalQuestions => _questions.length;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    _isSubmitted = widget.progress?.status == ProgressStatus.completed;
    if (_isSubmitted) {
      _calculateScore();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectAnswer(int optionIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = optionIndex;
    });
  }

  void _goToQuestion(int index) {
    if (index >= 0 && index < _totalQuestions) {
      _animationController.reset();
      setState(() {
        _currentQuestionIndex = index;
      });
      _animationController.forward();
    }
  }

  void _nextQuestion() {
    _goToQuestion(_currentQuestionIndex + 1);
  }

  void _previousQuestion() {
    _goToQuestion(_currentQuestionIndex - 1);
  }

  void _calculateScore() {
    int correct = 0;
    for (int i = 0; i < _totalQuestions; i++) {
      if (_answers[i] == _questions[i]['correct']) {
        correct++;
      }
    }
    _score = correct;
  }

  Future<void> _submitQuiz() async {
    // Check if all questions answered
    final unanswered = List.generate(_totalQuestions, (i) => i)
        .where((i) => !_answers.containsKey(i))
        .toList();
    
    if (unanswered.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('Please answer question ${unanswered.first + 1}'),
            ],
          ),
          backgroundColor: AppColors.mimosaGold,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Go',
            textColor: Colors.white,
            onPressed: () => _goToQuestion(unanswered.first),
          ),
        ),
      );
      return;
    }

    _calculateScore();
    setState(() {
      _isSubmitted = true;
    });

    widget.onQuizComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _buildResultsView(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator
        _buildStepIndicator(context),
        const SizedBox(height: AppSpacing.xl),

        // Question card with animation
        FadeTransition(
          opacity: _fadeAnimation,
          child: _buildQuestionCard(context),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Navigation
        _buildNavigation(context),
      ],
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    return Row(
      children: List.generate(_totalQuestions, (index) {
        final isAnswered = _answers.containsKey(index);
        final isCurrent = index == _currentQuestionIndex;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => _goToQuestion(index),
            child: Container(
              height: 4,
              margin: EdgeInsets.only(
                right: index < _totalQuestions - 1 ? 4 : 0,
              ),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.vivaMagenta
                    : isAnswered
                        ? AppColors.vivaMagenta.withValues(alpha: 0.4)
                        : AppColors.neutral200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final selectedOption = _answers[_currentQuestionIndex];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.vivaMagenta.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  'Q${_currentQuestionIndex + 1}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.vivaMagenta,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${_currentQuestionIndex + 1} of $_totalQuestions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Question text
          Text(
            question['question'] as String,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Options
          ...List.generate(
            (question['options'] as List).length,
            (optionIndex) {
              final option = (question['options'] as List)[optionIndex];
              final isSelected = selectedOption == optionIndex;
              final optionLabel = String.fromCharCode(65 + optionIndex); // A, B, C, D

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectAnswer(optionIndex),
                    borderRadius: AppSpacing.borderRadiusMd,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.vivaMagenta.withValues(alpha: 0.08)
                            : AppColors.neutral50,
                        borderRadius: AppSpacing.borderRadiusMd,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.vivaMagenta
                              : AppColors.neutral200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Option label circle
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.vivaMagenta
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.vivaMagenta
                                    : AppColors.neutral400,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                optionLabel,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.neutral600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          // Option text
                          Expanded(
                            child: Text(
                              option,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? AppColors.neutral900
                                    : AppColors.neutral700,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          // Checkmark for selected
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.vivaMagenta,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(BuildContext context) {
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex == _totalQuestions - 1;
    final hasAnswer = _answers.containsKey(_currentQuestionIndex);

    return Row(
      children: [
        // Previous button
        if (!isFirstQuestion)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _previousQuestion,
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neutral700,
                side: const BorderSide(color: AppColors.neutral300),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        
        if (!isFirstQuestion) const SizedBox(width: AppSpacing.md),
        
        // Next/Submit button
        Expanded(
          flex: isFirstQuestion ? 1 : 1,
          child: FilledButton.icon(
            onPressed: hasAnswer
                ? (isLastQuestion ? _submitQuiz : _nextQuestion)
                : null,
            icon: Icon(
              isLastQuestion ? Icons.check_rounded : Icons.arrow_forward_rounded,
              size: 20,
            ),
            label: Text(isLastQuestion ? 'Submit' : 'Next'),
            style: FilledButton.styleFrom(
              backgroundColor: isLastQuestion
                  ? AppColors.success
                  : AppColors.vivaMagenta,
              disabledBackgroundColor: AppColors.neutral200,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView(BuildContext context) {
    final percentage = (_score / _totalQuestions * 100).round();
    final isPassing = percentage >= 70;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPassing
                    ? [AppColors.success, AppColors.success.withValues(alpha: 0.8)]
                    : [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
              ),
              borderRadius: AppSpacing.borderRadiusLg,
              boxShadow: [
                BoxShadow(
                  color: (isPassing ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Trophy/icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPassing ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Status text
                Text(
                  isPassing ? 'Congratulations!' : 'Keep Trying!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isPassing
                      ? 'You passed the quiz'
                      : 'You need 70% to pass',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Score display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildScoreStat(context, '$_score', 'Correct'),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3),
                      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    ),
                    _buildScoreStat(context, '$percentage%', 'Score'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Answer review header
          Row(
            children: [
              Text(
                'Review Answers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$_score/$_totalQuestions correct',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Question reviews
          ...List.generate(
            _totalQuestions,
            (index) => _buildQuestionReview(context, index),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionReview(BuildContext context, int index) {
    final question = _questions[index];
    final correctOption = question['correct'] as int;
    final userAnswer = _answers[index];
    final isCorrect = userAnswer == correctOption;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withValues(alpha: 0.05)
            : AppColors.error.withValues(alpha: 0.05),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isCorrect
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isCorrect
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect ? Icons.check_rounded : Icons.close_rounded,
              size: 16,
              color: isCorrect ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q${index + 1}: ${question['question']}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                
                // User's answer
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall,
                    children: [
                      TextSpan(
                        text: 'Your answer: ',
                        style: TextStyle(color: AppColors.neutral500),
                      ),
                      TextSpan(
                        text: userAnswer != null
                            ? (question['options'] as List)[userAnswer]
                            : 'Not answered',
                        style: TextStyle(
                          color: isCorrect ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Correct answer (if wrong)
                if (!isCorrect) ...[
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: 'Correct: ',
                          style: TextStyle(color: AppColors.neutral500),
                        ),
                        TextSpan(
                          text: (question['options'] as List)[correctOption],
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
