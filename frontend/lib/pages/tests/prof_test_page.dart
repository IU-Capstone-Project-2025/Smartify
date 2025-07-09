import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:smartify/pages/api_server/api_server.dart';
import 'package:smartify/pages/recommendations/recommendation_screen.dart';

void main() {
  runApp(const SmartifyApp());
}

class SmartifyApp extends StatelessWidget {
  const SmartifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smartify Test',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const QuestionnairePage(),
    );
  }
}

enum QuestionType { singleChoice, multiChoice, scale }

class Question {
  final String text;
  final QuestionType type;
  final List<String>? options;
  final int? scaleMin;
  final int? scaleMax;
  final int? maxSelected;
  final String? block;
  final int? number;

  Question({
    required this.text,
    required this.type,
    this.options,
    this.scaleMin,
    this.scaleMax,
    this.maxSelected,
    this.block,
    this.number,
  });
}

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  List<Question> questions = [];
  final Map<int, dynamic> answers = {};
  final highlightColor = const Color(0xFF54D0C0);
  final Map<int, TextEditingController> _textControllers = {};

  Future<void> _submitQuestionnaire() async {
    final Map<String, dynamic> data = {
    "user_id": 0,
    "class": "",
    "region": "",
    "avg_grade": "",
    "favorite_subjects": [],
    "hard_subjects": [],
    "subject_scores": {},
    "interests": [],
    "values": [],
    "mbti_scores": {},
    "work_preferences": {
      "role": "",
      "place": "",
      "style": "",
      "exclude": "",
    },
  };
    for (final entry in answers.entries) {
      final index = entry.key;
      final value = entry.value;

      print("✔ ${index} = $value");

      switch (index) {
        case 0:
          data["class"] = value;
          break;
        case 1:
          data["region"] = value;
          break;
        case 2:
          data["avg_grade"] = value;
          break;
        case 3:
          data["favorite_subjects"] = value; // List<String>
          break;
        case 4:
          data["hard_subjects"] = value;
          break;
        case 5:
          data["subject_scores"]["Математика"] = value;
          break;
        case 6:
          data["subject_scores"]["Русский язык"] = value;
          break;
        case 7:
          data["subject_scores"]["Химия"] = value;
          break;
        case 8:
          data["subject_scores"]["Биология"] = value;
          break;
        case 9:
          data["subject_scores"]["Физика"] = value;
          break;
        case 10:
          data["subject_scores"]["Информатика"] = value;
          break;
        case 11:
          data["subject_scores"]["История"] = value;
          break;
        case 13:
          data["interests"] = value;
          break;
        case 14:
          data["values"] = value;
          break;
        case >= 16 && <= 40:
          final mbtiKey = "q${index - 5}";  // Например, q11…q35
          data["mbti_scores"][mbtiKey] = int.tryParse(value.toString()) ?? 0;
          break;
        case 41:
          data["work_preferences"]["role"] = value;
          break;
        case 42:
          data["work_preferences"]["place"] = value;
          break;
        case 43:
          data["work_preferences"]["style"] = value;
          break;
        case 44:
          data["work_preferences"]["exclude"] = value;
          break;
      }
    }
    final success = await ApiService.AddQuestionnaire(data);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Анкета отправлена!" : "Ошибка при отправке анкеты"),
      ),
    );
  }

  @override
  void dispose() {
    // Очищаем контроллеры при уничтожении виджета
    _textControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final text = await extractDocxText('assets/profession_test.docx');
    final parsed = parseQuestions(text);
    setState(() => questions = parsed);
  }

  Future<String> extractDocxText(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    final archive = ZipDecoder().decodeBytes(bytes.buffer.asUint8List());
    final docXml = archive.firstWhere((f) => f.name == 'word/document.xml');
    final document = XmlDocument.parse(utf8.decode(docXml.content as List<int>));
    final buffer = StringBuffer();

    for (var node in document.findAllElements('w:t')) {
      buffer.write(node.innerText);
      buffer.write('\n');
    }

    return buffer.toString();
  }

  List<Question> parseQuestions(String rawText) {
    final lines = rawText.split('\n');
    final List<Question> questions = [];

    String? currentQuestion;
    List<String> currentOptions = [];
    String? currentBlock;
    int? currentNumber;

    final checkboxRegex = RegExp(r'☐\s*([^\n☐]+)');
    final scaleLineRegex = RegExp(r'^(.+?):\s*\[\d\](?:\s*\[\d\])*$');
    final scaleItemRegex = RegExp(r'^(\d+)\.\s*(.+?)\s*\[\d[-–]?\d\]$');
    final numberedRegex = RegExp(r'^(\d+)\.\s+(.+)$');
    final blockRegex = RegExp(r'^БЛОК\s*\d+.*', caseSensitive: false);

    void saveCheckbox() {
      if (currentQuestion != null && currentOptions.isNotEmpty) {
        final isMulti = RegExp(r'выбери\s*(до)?\s*\d+', caseSensitive: false).hasMatch(currentQuestion!);
        final maxMatch = RegExp(r'выбери\s*(до)?\s*(\d+)', caseSensitive: false).firstMatch(currentQuestion!);
        final max = maxMatch != null ? int.tryParse(maxMatch.group(2) ?? '') : null;

        questions.add(Question(
          text: currentQuestion!,
          type: isMulti ? QuestionType.multiChoice : QuestionType.singleChoice,
          options: List.from(currentOptions),
          maxSelected: isMulti ? max : null,
          block: currentBlock,
          number: currentNumber,
        ));
      }
      currentQuestion = null;
      currentOptions.clear();
      currentNumber = null;
    }

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (blockRegex.hasMatch(line)) {
        currentBlock = line;
        continue;
      }

      final checkboxMatches = checkboxRegex.allMatches(line);
      if (checkboxMatches.isNotEmpty) {
        for (final match in checkboxMatches) {
          currentOptions.add(match.group(1)!.trim());
        }
        continue;
      }

      if (scaleLineRegex.hasMatch(line)) {
        final match = RegExp(r'^(.+?):').firstMatch(line);
        if (match != null) {
          questions.add(Question(
            text: match.group(1)!.trim(),
            type: QuestionType.scale,
            scaleMin: 1,
            scaleMax: 5,
            block: currentBlock,
          ));
        }
        continue;
      }

      if (scaleItemRegex.hasMatch(line)) {
        final match = scaleItemRegex.firstMatch(line);
        if (match != null) {
          final number = int.tryParse(match.group(1)!);
          final text = match.group(2)!.trim();
          questions.add(Question(
            text: text,
            type: QuestionType.scale,
            scaleMin: 1,
            scaleMax: 7,
            number: number,
            block: currentBlock,
          ));
        }
        continue;
      }

      final numMatch = numberedRegex.firstMatch(line);
      if (numMatch != null) {
        currentNumber = int.tryParse(numMatch.group(1)!);
        currentQuestion = numMatch.group(2)!.trim();
        continue;
      }

      if (currentOptions.isNotEmpty) {
        saveCheckbox();
      }

      currentQuestion = line;
    }

    saveCheckbox();
    return questions;
  }

  Widget buildQuestion(int index, Question question) {
    Widget content;

switch (question.type) {
  case QuestionType.singleChoice:
    String? selected = answers[index];

    final otherOption = question.options!.firstWhere(
      (o) => o.toLowerCase().contains('другое'),
      orElse: () => '',
    );

    // Инициализируем контроллер один раз
    if (!_textControllers.containsKey(index)) {
      _textControllers[index] = TextEditingController();
    }

    // Восстанавливаем значение, если оно кастомное
    if (selected != null &&
        !question.options!.contains(selected) &&
        otherOption.isNotEmpty) {
      _textControllers[index]!.text = selected;
    }

    content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        ...question.options!
            .where((o) => o != otherOption)
            .map(
              (option) => RadioListTile<String>(
                activeColor: highlightColor,
                title:
                    Text(option, style: const TextStyle(color: Colors.black)),
                value: option,
                groupValue:
                    question.options!.contains(selected) ? selected : '',
                onChanged: (value) =>
                    setState(() => answers[index] = value),
              ),
            ),
        if (otherOption.isNotEmpty)
          RadioListTile<String>(
            activeColor: highlightColor,
            value: '__other__',
            groupValue: (!question.options!.contains(selected) &&
                    selected != null)
                ? '__other__'
                : '',
            onChanged: (_) {
              setState(() {
                answers[index] = _textControllers[index]!.text;
              });
            },
            title: Row(
              children: [
                const Text(
                  'Другое:',
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _textControllers[index],
                    decoration: const InputDecoration(
                      hintText: 'Ваш вариант',
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      answers[index] = value;
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    break;


      case QuestionType.multiChoice:
        final selected = (answers[index] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
        final int max = question.maxSelected ?? 999;

        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ...question.options!.map((option) {
              final isChecked = selected.contains(option);
              final isLimitReached = !isChecked && selected.length >= max;

              return CheckboxListTile(
                activeColor: highlightColor,
                title: Text(option, style: const TextStyle(color: Colors.black)),
                value: isChecked,
                onChanged: isLimitReached && !isChecked
                    ? null
                    : (checked) {
                        setState(() {
                          if (checked == true) {
                            selected.add(option);
                          } else {
                            selected.remove(option);
                          }
                          answers[index] = List.from(selected);
                        });
                      },
              );
            }),
            if (question.maxSelected != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Выбрано: ${selected.length} из $max',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        );
        break;

      case QuestionType.scale:
        double value = (answers[index]?.toDouble() ?? question.scaleMin!.toDouble());
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${question.text} (${question.scaleMin}–${question.scaleMax})',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Slider(
              activeColor: highlightColor,
              inactiveColor: highlightColor.withOpacity(0.3),
              value: value,
              min: question.scaleMin!.toDouble(),
              max: question.scaleMax!.toDouble(),
              divisions: question.scaleMax! - question.scaleMin!,
              label: value.toInt().toString(),
              onChanged: (newValue) => setState(() => answers[index] = newValue.toInt()),
            ),
          ],
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index == 0 || questions[index - 1].block != question.block)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              question.block ?? '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: highlightColor),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.number != null)
              Text('${question.number}. ', style: TextStyle(fontWeight: FontWeight.bold, color: highlightColor)),
            Expanded(child: content),
          ],
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('logo.png', height: 50),
        centerTitle: true,
      ),
      body: questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: questions.length + 1,
              itemBuilder: (context, index) {
                if (index == questions.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: highlightColor,
                      ),
                      onPressed: () {
                        _submitQuestionnaire();
                        for (final entry in answers.entries) {
                          final q = questions[entry.key];
                          final answer = entry.value is List
                              ? (entry.value as List).join(', ')
                              : entry.value;
                          print('${q.number ?? "-"} [${q.block ?? ""}] ${q.text}: $answer');
                        }
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecommendationScreen(), // не забудь импортировать
                          ),
                        );
                      },
                      child: const Text(
                        'Завершить',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: buildQuestion(index, questions[index]),
                );
              },
            ),
    );
  }
}
