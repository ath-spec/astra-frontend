import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilingQuestion {
  const ProfilingQuestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.options,
    this.selectedOptionIndex,
  });

  final int id;
  final String title;
  final String subtitle;
  final List<String> options;
  final int? selectedOptionIndex;

  ProfilingQuestion copyWith({int? selectedOptionIndex}) {
    return ProfilingQuestion(
      id: id,
      title: title,
      subtitle: subtitle,
      options: options,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
    );
  }
}

class ProfilingState {
  const ProfilingState({
    required this.currentQuestionIndex,
    required this.questions,
    this.isSubmitting = false,
    this.isSubmitted = false,
  });

  final int currentQuestionIndex;
  final List<ProfilingQuestion> questions;
  final bool isSubmitting;
  final bool isSubmitted;

  ProfilingQuestion get currentQuestion => questions[currentQuestionIndex];
  bool get canContinue => currentQuestion.selectedOptionIndex != null;

  ProfilingState copyWith({
    int? currentQuestionIndex,
    List<ProfilingQuestion>? questions,
    bool? isSubmitting,
    bool? isSubmitted,
  }) {
    return ProfilingState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      questions: questions ?? this.questions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class ProfilingNotifier extends StateNotifier<ProfilingState> {
  ProfilingNotifier()
      : super(
          const ProfilingState(
            currentQuestionIndex: 0,
            questions: _initialQuestions,
          ),
        );

  static const List<ProfilingQuestion> _initialQuestions = [
    ProfilingQuestion(
      id: 1,
      title: 'What is your yearly income?',
      subtitle: 'We need this to check if you are investing the correct amounts each month',
      options: [
        'Less than ₹10 Lakhs',
        '₹10L to ₹25 Lakhs',
        '₹25L to ₹50 Lakhs',
        'More than ₹50 Lakhs',
      ],
    ),
    ProfilingQuestion(
      id: 2,
      title: 'What is your primary source of income?',
      subtitle: 'To evaluate how stable your income is',
      options: [
        "I'm a salaried employee",
        'I run a business',
        "I'm retired with pension",
        'My investments give me income',
      ],
    ),
    ProfilingQuestion(
      id: 3,
      title: "What's the total value of your investments? Stocks, FDs etc",
      subtitle: 'Include all financial assets you own',
      options: [
        'Less than ₹25 Lakhs',
        '₹25 Lakhs to ₹50 Lakhs',
        '₹50 Lakhs to ₹2 Crores',
        '₹2 Crores to ₹5 Crores',
        'More than ₹5 Crores',
      ],
    ),
    ProfilingQuestion(
      id: 4,
      title: 'What is your primary investment goal?',
      subtitle: 'To align portfolio strategies with your financial objectives',
      options: [
        'Long term wealth creation',
        'Retirement planning',
        'Regular passive income',
        'Short term capital growth',
      ],
    ),
  ];

  void selectOption(int questionIndex, int optionIndex) {
    final updatedQuestions = List<ProfilingQuestion>.from(state.questions);
    updatedQuestions[questionIndex] = updatedQuestions[questionIndex].copyWith(
      selectedOptionIndex: optionIndex,
    );
    state = state.copyWith(questions: updatedQuestions);
  }

  bool nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
      return true;
    }
    return false;
  }

  bool previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
      return true;
    }
    return false;
  }

  Future<void> submitProfiling() async {
    state = state.copyWith(isSubmitting: true, isSubmitted: false);
    await Future.delayed(const Duration(milliseconds: 1500));
    state = state.copyWith(isSubmitting: false, isSubmitted: true);
  }

  void reset() {
    final resetQuestions = _initialQuestions.map((q) => ProfilingQuestion(
      id: q.id,
      title: q.title,
      subtitle: q.subtitle,
      options: q.options,
      selectedOptionIndex: null,
    )).toList();
    state = ProfilingState(
      currentQuestionIndex: 0,
      questions: resetQuestions,
      isSubmitting: false,
      isSubmitted: false,
    );
  }
}

final profilingProvider = StateNotifierProvider<ProfilingNotifier, ProfilingState>((ref) {
  return ProfilingNotifier();
});
