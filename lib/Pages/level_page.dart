import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kid_coder/widgets/explainer_widget.dart';

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
    if (_currentIndex < _totalItems - 1) {
      _currentIndex++;
      final screenWidth = MediaQuery.of(context).size.width;
      _scrollController.animateTo(
        _currentIndex * screenWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  int _totalItems = 0;

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
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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

            return Stack(
              children: [
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentLevelQuestions.length,
                  itemBuilder: (context, index) {
                    final question = currentLevelQuestions[index];
                    final questionType = question["questionType"];
                    final content = question["content"];
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: questionType == "explainer"
                          ? ExplainerWidget(content: content)
                          : Text(content),
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _scrollToNext,
                    child: const Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            );
          }
          return const Text("No data");
        },
      ),
    );
  }
}
