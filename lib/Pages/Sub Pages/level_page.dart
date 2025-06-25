import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kid_coder/widgets/button_widget.dart';
import 'package:kid_coder/widgets/explainer_widget.dart';
import 'package:kid_coder/widgets/mcq_widget.dart';
import 'package:kid_coder/widgets/level_interrupt_window.dart';
import 'package:kid_coder/widgets/level_end_window.dart';
import 'package:kid_coder/widgets/code_widget.dart';
import 'package:kid_coder/widgets/arrange_widget.dart';

class LevelPage extends StatefulWidget {
  final int level;
  final String levelType;
  const LevelPage({super.key, required this.levelType, required this.level});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  late Future _levelDataFuture;
  late ScrollController _scrollController;
  int _currentIndex = 0;
  int _totalItems = 0;

  // Dialog state
  bool _showInterruptWindow = false;
  bool _showEndWindow = false;
  bool _mcqAnswered = false;

  // Score tracking
  int _totalQuestions = 0;
  int _correctAnswers = 0;
  Map<int, bool> _questionResults = {}; // Track results by question index

  @override
  void initState() {
    super.initState();
    _levelDataFuture = _loadLevelsData();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToNext() {
    setState(() {
      _mcqAnswered = false;
    });
    if (_currentIndex < _totalItems - 1) {
      setState(() {
        _currentIndex++;
      });
      final screenWidth = MediaQuery.of(context).size.width;
      _scrollController.animateTo(
        _currentIndex * screenWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last question, show end window
      setState(() {
        _showEndWindow = true;
      });
    }
  }

  void _onQuestionAnswered(bool isCorrect) {
    setState(() {
      _questionResults[_currentIndex] = isCorrect;
      if (isCorrect) {
        _correctAnswers++;
      }
    });
  }

  Future _loadLevelsData() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/JAVA/levels_data.json',
    );
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final levelNumber = widget.level;
    
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _showInterruptWindow = true;
        });
        return false;
      },
      child: Scaffold(
        // appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: FutureBuilder(
          future: _levelDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
      
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
      
            if (snapshot.hasData) {
              final data = snapshot.data!;
              final levels = data["listOfLevels"] as List;
              final currentLevel = levels[levelNumber - 1];
              final currentLevelQuestions = currentLevel["questions"] as List;
              _totalItems = currentLevelQuestions.length;
              
              // Initialize total questions count (only count scorable questions)
              if (_totalQuestions == 0) {
                _totalQuestions = currentLevelQuestions.where((q) => 
                  q["questionType"] == "mcq" || 
                  q["questionType"] == "arrange" || 
                  q["questionType"] == "code"
                ).length;
              }
      
              double progress = (_totalItems == 0)
                  ? 0
                  : (_currentIndex + 1) / _totalItems;
      
              return Stack(
                children: [
                  // Main content
                  Opacity(
                    opacity: _showInterruptWindow || _showEndWindow ? 0.2 : 1.0,
                    child: IgnorePointer(
                      ignoring: _showInterruptWindow || _showEndWindow,
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          // Back Button and Progress Bar Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                  onPressed: () {
                                    setState(() {
                                      _showInterruptWindow = true;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      height: 16,
                                      color: const Color(0xFF2C353A),
                                      child: Stack(
                                        children: [
                                          FractionallySizedBox(
                                            widthFactor: progress,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green[700],
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              controller: _scrollController,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: currentLevelQuestions.length,
                              itemBuilder: (context, index) {
                                final question = currentLevelQuestions[index];
                                final questionType = question["questionType"];
                                if (questionType == "explainer") {
                                  final content = question["content"];
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ExplainerWidget(content: content),
                                  );
                                } else if (questionType == "mcq") {
                                  final content = question["content"] ?? "";
                                  final options = (question["options"] as List?)?.cast<String>() ?? [];
                                  final correctAnswer = question["correctAnswer"] ?? "";
                                  final explanation = question["explanation"];
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: McqWidget(
                                      question: content,
                                      options: options,
                                      correctAnswer: correctAnswer,
                                      explanation: explanation,
                                      onAnswered: (isCorrect) {
                                        setState(() {
                                          _mcqAnswered = true;
                                          _onQuestionAnswered(isCorrect);
                                        });
                                      },
                                    ),
                                  );
                                } else if (questionType == "code") {
                                  // Show the code widget for code questions
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: CodeWidget(
                                      levelData: {
                                        ...currentLevel,
                                        'questions': [question],
                                      },
                                      onAnswered: (isCorrect) {
                                        setState(() {
                                          _mcqAnswered = true;
                                          _onQuestionAnswered(isCorrect);
                                        });
                                      },
                                    ),
                                  );
                                } else if (questionType == "arrange") {
                                  final content = question["content"] ?? "";
                                  final options = (question["options"] as List?)?.cast<String>() ?? [];
                                  final correctOrder = (question["correctAnswer"] as List?)?.cast<String>() ?? [];
                                  final explanation = question["explanation"];
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ArrangeWidget(
                                      prompt: content,
                                      tokens: options,
                                      correctOrder: correctOrder,
                                      explanation: explanation,
                                      onAnswered: (isCorrect) {
                                        setState(() {
                                          _mcqAnswered = true;
                                          _onQuestionAnswered(isCorrect);
                                        });
                                      },
                                    ),
                                  );
                                } else {
                                  // fallback for unknown type
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(child: Text("Unsupported question type")),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Next button
                  if (!_showInterruptWindow && !_showEndWindow)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Builder(
                        builder: (context) {
                          final question = currentLevelQuestions[_currentIndex];
                          final questionType = question["questionType"];
                          final isMcq = questionType == "mcq";
                          final isArrange = questionType == "arrange";
                          final isCode = questionType == "code";
                          final nextEnabled = (!isMcq && !isArrange && !isCode) || _mcqAnswered;
                          return Opacity(
                            opacity: nextEnabled ? 1.0 : 0.5,
                            child: IgnorePointer(
                              ignoring: !nextEnabled,
                              child: ButtonWidget(
                                color: Colors.green[500]!,
                                text: _currentIndex == _totalItems - 1 ? "Finish" : "Next",
                                shadowColor: Colors.green[800]!,
                                onPressed: _scrollToNext,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  // Interrupt window overlay
                  if (_showInterruptWindow)
                    Positioned.fill(
                      child: LevelInterruptWindow(
                        onExit: () {
                          Navigator.of(context).pop();
                        },
                        onCancel: () {
                          setState(() {
                            _showInterruptWindow = false;
                          });
                        },
                      ),
                    ),
                  // End window overlay
                  if (_showEndWindow)
                    Positioned.fill(
                      child: LevelEndWindow(
                        totalQuestions: _totalQuestions,
                        correctAnswers: _correctAnswers,
                        onClose: () {
                          Navigator.of(context).pop({'levelCompleted': widget.level});
                        },
                      ),
                    ),
                ],
              );
            }
            return const Text("No data");
          },
        ),
      ),
    );
  }
}
