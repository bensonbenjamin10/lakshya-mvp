import 'package:flutter/material.dart';
import 'package:lakshya_mvp/models/course_module.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Quiz widget for quiz modules
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

class _QuizWidgetState extends State<QuizWidget> {
  int _currentQuestionIndex = 0;
  Map<int, String?> _answers = {};
  bool _isSubmitted = false;
  int _score = 0;
  int _totalQuestions = 5;

  // Sample quiz questions
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

  @override
  void initState() {
    super.initState();
    _isSubmitted = widget.progress?.status == ProgressStatus.completed;
    if (_isSubmitted) {
      _calculateScore();
    }
  }

  void _selectAnswer(int questionIndex, int optionIndex) {
    setState(() {
      _answers[questionIndex] = _questions[questionIndex]['options'][optionIndex];
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _calculateScore() {
    int correct = 0;
    for (int i = 0; i < _totalQuestions; i++) {
      final correctAnswer = _questions[i]['options'][_questions[i]['correct']];
      if (_answers[i] == correctAnswer) {
        correct++;
      }
    }
    _score = correct;
  }

  Future<void> _submitQuiz() async {
    if (_answers.length < _totalQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    _calculateScore();
    setState(() {
      _isSubmitted = true;
    });

    widget.onQuizComplete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quiz completed! Score: $_score/$_totalQuestions'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _buildResultsView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quiz header
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.vivaMagenta.withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.vivaMagenta.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.quiz, color: AppColors.vivaMagenta, size: 32),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz: ${widget.module.title}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.vivaMagenta,
                          ),
                    ),
                    Text(
                      'Question ${_currentQuestionIndex + 1} of $_totalQuestions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Progress indicator
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _totalQuestions,
          backgroundColor: AppColors.neutral200,
          color: AppColors.vivaMagenta,
          minHeight: 8,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Current question
        _buildQuestion(_currentQuestionIndex),
        const SizedBox(height: AppSpacing.xl),

        // Navigation buttons
        Row(
          children: [
            if (_currentQuestionIndex > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _previousQuestion,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
              ),
            if (_currentQuestionIndex > 0) const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _currentQuestionIndex < _totalQuestions - 1
                    ? _nextQuestion
                    : _submitQuiz,
                icon: Icon(_currentQuestionIndex < _totalQuestions - 1
                    ? Icons.arrow_forward
                    : Icons.check),
                label: Text(_currentQuestionIndex < _totalQuestions - 1
                    ? 'Next'
                    : 'Submit Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vivaMagenta,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestion(int index) {
    final question = _questions[index];
    final selectedAnswer = _answers[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'] as String,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(
          (question['options'] as List).length,
          (optionIndex) {
            final option = (question['options'] as List)[optionIndex];
            final isSelected = selectedAnswer == option;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: InkWell(
                onTap: () => _selectAnswer(index, optionIndex),
                borderRadius: AppSpacing.borderRadiusSm,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.vivaMagenta.withValues(alpha: 0.1)
                        : AppColors.neutral50,
                    borderRadius: AppSpacing.borderRadiusSm,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.vivaMagenta
                          : AppColors.neutral200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.vivaMagenta
                                : AppColors.neutral400,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColors.vivaMagenta
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          option,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    final percentage = (_score / _totalQuestions * 100).round();
    final isPassing = percentage >= 70;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: isPassing
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.error.withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: isPassing ? AppColors.success : AppColors.error,
            ),
          ),
          child: Column(
            children: [
              Icon(
                isPassing ? Icons.check_circle : Icons.cancel,
                size: 64,
                color: isPassing ? AppColors.success : AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isPassing ? 'Quiz Passed!' : 'Quiz Failed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPassing ? AppColors.success : AppColors.error,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Score: $_score/$_totalQuestions ($percentage%)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Question review
        Text(
          'Review Your Answers',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(
          _totalQuestions,
          (index) => _buildQuestionReview(index),
        ),
      ],
    );
  }

  Widget _buildQuestionReview(int index) {
    final question = _questions[index];
    final correctAnswer = question['options'][question['correct']];
    final userAnswer = _answers[index];
    final isCorrect = userAnswer == correctAnswer;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: isCorrect
          ? AppColors.success.withValues(alpha: 0.05)
          : AppColors.error.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Question ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              question['question'] as String,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your answer: ${userAnswer ?? "Not answered"}',
              style: TextStyle(
                color: isCorrect ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isCorrect)
              Text(
                'Correct answer: $correctAnswer',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

