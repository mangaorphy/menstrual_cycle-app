import '../models/quiz_question.dart';

class QuizData {
  static final Map<String, Quiz> _quizzes = {
    'quiz_basic': Quiz(
      id: 'quiz_basic',
      title: 'Basic Knowledge Quiz',
      description: 'Test your understanding of menstrual cycles and health',
      questions: [
        QuizQuestion(
          id: 'q1',
          question: 'How long is the average menstrual cycle?',
          options: ['21 days', '28 days', '35 days', '42 days'],
          correctAnswerIndex: 1,
          explanation: 'The average menstrual cycle is 28 days, though cycles between 21-35 days are considered normal.',
        ),
        QuizQuestion(
          id: 'q2',
          question: 'During which phase does ovulation typically occur?',
          options: ['Menstrual phase', 'Follicular phase', 'Ovulatory phase', 'Luteal phase'],
          correctAnswerIndex: 2,
          explanation: 'Ovulation occurs during the ovulatory phase, typically around day 14 of a 28-day cycle.',
        ),
        QuizQuestion(
          id: 'q3',
          question: 'How long does the average menstrual period last?',
          options: ['2-4 days', '3-7 days', '7-10 days', '10-14 days'],
          correctAnswerIndex: 1,
          explanation: 'The average menstrual period lasts 3-7 days, though this can vary from person to person.',
        ),
        QuizQuestion(
          id: 'q4',
          question: 'What hormone is primarily responsible for triggering ovulation?',
          options: ['Estrogen', 'Progesterone', 'Luteinizing Hormone (LH)', 'Follicle Stimulating Hormone (FSH)'],
          correctAnswerIndex: 2,
          explanation: 'A surge in Luteinizing Hormone (LH) triggers ovulation, causing the egg to be released from the ovary.',
        ),
        QuizQuestion(
          id: 'q5',
          question: 'At what age do most people typically start menstruating?',
          options: ['8-10 years', '10-12 years', '12-15 years', '15-18 years'],
          correctAnswerIndex: 2,
          explanation: 'Most people start menstruating between ages 12-15, though it can begin anywhere from 8-16 years old.',
        ),
      ],
    ),
    'quiz_hygiene': Quiz(
      id: 'quiz_hygiene',
      title: 'Hygiene & Products Quiz',
      description: 'Learn about menstrual products and proper hygiene',
      questions: [
        QuizQuestion(
          id: 'h1',
          question: 'How often should you change a tampon?',
          options: ['Every 2-4 hours', 'Every 4-8 hours', 'Every 8-12 hours', 'Once a day'],
          correctAnswerIndex: 1,
          explanation: 'Tampons should be changed every 4-8 hours to prevent bacterial growth and reduce the risk of TSS.',
        ),
        QuizQuestion(
          id: 'h2',
          question: 'What is the maximum time a menstrual cup can be worn?',
          options: ['4 hours', '8 hours', '12 hours', '24 hours'],
          correctAnswerIndex: 2,
          explanation: 'A menstrual cup can typically be worn for up to 12 hours, depending on your flow.',
        ),
        QuizQuestion(
          id: 'h3',
          question: 'Which is the most environmentally friendly menstrual product?',
          options: ['Disposable pads', 'Tampons', 'Menstrual cups', 'Panty liners'],
          correctAnswerIndex: 2,
          explanation: 'Menstrual cups are reusable and can last several years, making them the most environmentally friendly option.',
        ),
        QuizQuestion(
          id: 'h4',
          question: 'What should you do before and after handling menstrual products?',
          options: ['Wash your hands', 'Use hand sanitizer', 'Both A and B', 'Nothing special'],
          correctAnswerIndex: 2,
          explanation: 'Always wash your hands or use hand sanitizer before and after handling menstrual products to maintain hygiene.',
        ),
        QuizQuestion(
          id: 'h5',
          question: 'How should used pads and tampons be disposed of?',
          options: ['Flush down toilet', 'Wrap and put in trash', 'Bury in garden', 'Burn them'],
          correctAnswerIndex: 1,
          explanation: 'Used pads and tampons should be wrapped and disposed of in the trash. Never flush them as they can clog pipes.',
        ),
      ],
    ),
    'quiz_health': Quiz(
      id: 'quiz_health',
      title: 'Health & Symptoms Quiz',
      description: 'Understand menstrual symptoms and when to seek help',
      questions: [
        QuizQuestion(
          id: 's1',
          question: 'Which of these symptoms during menstruation is NOT normal?',
          options: ['Mild cramping', 'Heavy bleeding that soaks a pad/tampon every hour', 'Breast tenderness', 'Mood changes'],
          correctAnswerIndex: 1,
          explanation: 'Heavy bleeding that soaks a pad or tampon every hour for several hours is not normal and should be evaluated by a doctor.',
        ),
        QuizQuestion(
          id: 's2',
          question: 'What can help reduce menstrual cramps?',
          options: ['Heat therapy', 'Light exercise', 'Over-the-counter pain relievers', 'All of the above'],
          correctAnswerIndex: 3,
          explanation: 'Heat therapy, light exercise, and appropriate pain relievers can all help reduce menstrual cramps.',
        ),
        QuizQuestion(
          id: 's3',
          question: 'When should you see a doctor about your periods?',
          options: ['Periods lasting longer than 7 days', 'Severe pain that interferes with daily activities', 'Irregular periods after age 16', 'All of the above'],
          correctAnswerIndex: 3,
          explanation: 'All of these situations warrant a consultation with a healthcare provider to rule out any underlying conditions.',
        ),
        QuizQuestion(
          id: 's4',
          question: 'What is PMS?',
          options: ['A serious medical condition', 'Physical and emotional symptoms before menstruation', 'A type of menstrual product', 'A phase of the menstrual cycle'],
          correctAnswerIndex: 1,
          explanation: 'PMS (Premenstrual Syndrome) refers to physical and emotional symptoms that occur before menstruation.',
        ),
        QuizQuestion(
          id: 's5',
          question: 'What foods might help reduce period symptoms?',
          options: ['Foods high in iron', 'Foods rich in omega-3 fatty acids', 'Calcium-rich foods', 'All of the above'],
          correctAnswerIndex: 3,
          explanation: 'Iron-rich foods help replace lost iron, omega-3s can reduce inflammation, and calcium may help with cramps.',
        ),
      ],
    ),
    'quiz_myths': Quiz(
      id: 'quiz_myths',
      title: 'Myths & Facts Quiz',
      description: 'Separate myths from facts about menstruation',
      questions: [
        QuizQuestion(
          id: 'm1',
          question: 'True or False: You can\'t swim during your period.',
          options: ['True', 'False'],
          correctAnswerIndex: 1,
          explanation: 'False! You can absolutely swim during your period. Water pressure prevents menstrual fluid from flowing out.',
        ),
        QuizQuestion(
          id: 'm2',
          question: 'True or False: You can get pregnant during your period.',
          options: ['True', 'False'],
          correctAnswerIndex: 0,
          explanation: 'True! While less likely, pregnancy can occur during menstruation, especially with shorter cycles.',
        ),
        QuizQuestion(
          id: 'm3',
          question: 'True or False: Exercise makes period cramps worse.',
          options: ['True', 'False'],
          correctAnswerIndex: 1,
          explanation: 'False! Light to moderate exercise can actually help reduce period cramps by releasing endorphins.',
        ),
        QuizQuestion(
          id: 'm4',
          question: 'True or False: Periods sync up when people live together.',
          options: ['True', 'False'],
          correctAnswerIndex: 1,
          explanation: 'False! Scientific studies have not found evidence for menstrual synchrony or "period syncing."',
        ),
        QuizQuestion(
          id: 'm5',
          question: 'True or False: You lose a lot of blood during menstruation.',
          options: ['True', 'False'],
          correctAnswerIndex: 1,
          explanation: 'False! The average menstrual flow is only about 30-40ml of blood (2-3 tablespoons) over the entire cycle.',
        ),
      ],
    ),
  };

  static Quiz? getQuiz(String quizId) {
    return _quizzes[quizId];
  }

  static List<Quiz> getAllQuizzes() {
    return _quizzes.values.toList();
  }
}
