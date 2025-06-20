import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kid_coder/Pages/Sub%20Pages/level_page.dart';
import 'package:kid_coder/widgets/chapter_tile.dart';
import 'package:kid_coder/widgets/level_tile.dart';
import 'package:kid_coder/widgets/level_start_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // BEST PRACTICE: Store the future in a state variable.
  late Future<Map<String, dynamic>> _mapDataFuture;
  late Future<Map<String, dynamic>> _levelsDataFuture;
  
  // State for level start window
  bool _showStartWindow = false;
  Map<String, dynamic>? _selectedLevelData;
  String? _selectedLevelType;
  int? _selectedLevelNumber;

  // Store tiles in state for mutation
  List<dynamic> _tiles = [];

  @override
  void initState() {
    super.initState();
    // Call getData() only ONCE when the widget is first created.
    _mapDataFuture = _loadMapData();
    _levelsDataFuture = _loadLevelsData();
    _loadUnlocks();
  }

  Future<void> _loadUnlocks() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedLevels = prefs.getStringList('unlockedLevels') ?? ['1'];
    setState(() {
      for (var tile in _tiles) {
        if (tile['type'] == 'level') {
          tile['isUnlocked'] = unlockedLevels.contains(tile['level'].toString());
        }
      }
    });
  }

  Future<void> _saveUnlocks() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedLevels = _tiles
        .where((tile) => tile['type'] == 'level' && tile['isUnlocked'] == true)
        .map((tile) => tile['level'].toString())
        .toList();
    await prefs.setStringList('unlockedLevels', unlockedLevels);
  }

  Future<Map<String, dynamic>> _loadMapData() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/JAVA/map_data.json',
    );
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    // Store tiles in state for mutation
    _tiles = List.from(data['ListOfTiles']);
    // print(data);
    return data;
  }

  Future<Map<String, dynamic>> _loadLevelsData() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/JAVA/levels_data.json',
    );
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return data;
  }

  void _showLevelStartWindow(String levelType, int levelNumber) async {
    // Load levels data to get the level description
    final levelsData = await _levelsDataFuture;
    final levels = levelsData["listOfLevels"] as List;
    final levelData = levels[levelNumber - 1];
    
    setState(() {
      _selectedLevelData = levelData;
      _selectedLevelType = levelType;
      _selectedLevelNumber = levelNumber;
      _showStartWindow = true;
    });
  }

  Future<void> _startLevel() async {
    if (_selectedLevelType != null && _selectedLevelNumber != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LevelPage(
            levelType: _selectedLevelType!,
            level: _selectedLevelNumber!,
          ),
        ),
      );
      setState(() {
        _showStartWindow = false;
        _selectedLevelData = null;
        _selectedLevelType = null;
        _selectedLevelNumber = null;
      });
      // Unlock next level if completed
      if (result != null && result['levelCompleted'] != null) {
        _unlockNextLevel(result['levelCompleted']);
      }
    }
  }

  void _unlockNextLevel(int completedLevel) async {
    // Find the next level in your tiles list and set isUnlocked = true
    for (var i = 0; i < _tiles.length; i++) {
      final tile = _tiles[i];
      if (tile['type'] == 'level' && tile['level'] == completedLevel + 1) {
        setState(() {
          tile['isUnlocked'] = true;
        });
        break;
      }
    }
    await _saveUnlocks();
  }

  @override
  Widget build(BuildContext context) {
    const List<double> alignmentPattern = [
      // A little off the edge
      0.3,
      0.0,
      -0.4,
      -0.7, // A little off the edge
      -0.4,
      0.0,
      0.5,
      0.7,
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Homepage'),
      ),
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            // Use the state variable here
            future: _mapDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.hasData) {
                // Use _tiles from state
                final tiles = _tiles;

                return Center(
                  child: SizedBox(
                    width: 250,
                    child: ListView.builder(
                      // FIX: You must provide an itemCount.
                      itemCount: tiles.length,
                      itemBuilder: (context, index) {
                        // final levelData = tiles[index];
                        // final String type =
                        //     levelData['levelType']; // <-- Now this is safe.
                        final tileData = tiles[index];
                        final String type = tileData['type'];
                        if (type == 'chapter') {
                          return ChapterTile(title: tileData['title']);
                        } else {
                          final levelType = tileData['levelType'];
                          final patternIndex = index % alignmentPattern.length;
                          final alignmentX = alignmentPattern[patternIndex];
                          final color = tileData['color'];
                          final isUnlocked = tileData['isUnlocked'] ?? false;

                          Color tileColor;
                          Color shadowColor;
                          VoidCallback? onTap;

                          if (isUnlocked) {
                            tileColor = color == "blue"
                                ? Colors.blue
                                : color == "green"
                                    ? Colors.green
                                    : Colors.red;
                            shadowColor = color == "blue"
                                ? Colors.blue[800]!
                                : color == "green"
                                    ? Colors.green[800]!
                                    : Colors.red[800]!;
                            onTap = () => _showLevelStartWindow(
                              levelType,
                              tileData['level'],
                            );
                          } else {
                            tileColor = Colors.grey;
                            shadowColor = Colors.grey[700]!;
                            onTap = () {};
                          }

                          return Align(
                            alignment: Alignment(alignmentX, 0),
                            child: LevelTile(
                              icon: levelType == 'explainer'
                                  ? Icons.book
                                  : levelType == 'mcq'
                                      ? Icons.help_outline_rounded
                                      : Icons.code,
                              onTap: onTap,
                              color: tileColor,
                              shadowColor: shadowColor,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              } else {
                // This case handles when snapshot has no data.
                return const Center(child: Text('No data found.'));
              }
            },
          ),
          // Level start window overlay
          if (_showStartWindow && _selectedLevelData != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: LevelStartWindow(
                  levelDescription: _selectedLevelData!["levelDescription"],
                  onStart: _startLevel,
                  onClose: () {
                    setState(() {
                      _showStartWindow = false;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
