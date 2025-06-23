import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kid_coder/Pages/Sub%20Pages/level_page.dart';
import 'package:kid_coder/widgets/chapter_tile.dart';
import 'package:kid_coder/widgets/level_tile.dart';
import 'package:kid_coder/widgets/level_start_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kid_coder/widgets/chapter_title_tile.dart';

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

  final ScrollController _scrollController = ScrollController();
  int _currentChapter = 1;
  String _currentChapterTitle = '';
  String _currentChapterColor = 'blue';

  @override
  void initState() {
    super.initState();
    // Call getData() only ONCE when the widget is first created.
    _mapDataFuture = _loadMapData();
    _levelsDataFuture = _loadLevelsData();
    _loadUnlocks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_tiles.isEmpty) return;
    // Estimate the first visible item index
    final itemHeight = 56.0 + 20.0; // LevelTile height + margin
    final offset = _scrollController.offset;
    int firstVisibleIndex = (offset / itemHeight).floor();
    if (firstVisibleIndex < 0) firstVisibleIndex = 0;
    if (firstVisibleIndex >= _tiles.length) firstVisibleIndex = _tiles.length - 1;
    // Find the nearest level tile from the first visible index
    for (int i = firstVisibleIndex; i >= 0; i--) {
      final tile = _tiles[i];
      if (tile['type'] == 'level') {
        final chapter = tile['chapter'] as int;
        if (chapter != _currentChapter) {
          final chapterTile = _tiles.firstWhere((t) => t['type'] == 'chapter' && t['chapter'] == chapter, orElse: () => null);
          setState(() {
            _currentChapter = chapter;
            _currentChapterTitle = chapterTile != null ? chapterTile['title'] : '';
            _currentChapterColor = chapterTile != null ? chapterTile['color'] : 'blue';
          });
        }
        break;
      }
    }
  }

  Color _getChapterColor(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue[700]!;
      case 'green':
        return Colors.green[700]!;
      case 'red':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
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
      0.566,
      0.0,
      -0.566,
      -0.8,
      -0.566,
      0.0,
      0.566,
      0.8,
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
            future: _mapDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.hasData) {
                final tiles = _tiles;
                // Set initial chapter info based on the first visible level
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _onScroll();
                });
                return Column(
                  children: [
                    ChapterTitleTile(
                      chapterNumber: _currentChapter,
                      title: _currentChapterTitle,
                      color: _getChapterColor(_currentChapterColor),
                    ),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: 250,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: tiles.length,
                            itemBuilder: (context, index) {
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
                                VoidCallback? onTap;
                                String imageAsset;
                                if (isUnlocked) {
                                  if (color == "blue") {
                                    imageAsset = 'assets/images/level_tiles/level_tile_blue.png';
                                  } else if (color == "green") {
                                    imageAsset = 'assets/images/level_tiles/level_tile_green.png';
                                  } else if (color == "red") {
                                    imageAsset = 'assets/images/level_tiles/level_tile_red.png';
                                  } else {
                                    imageAsset = 'assets/images/level_tiles/level_tile_grey.png';
                                  }
                                  onTap = () => _showLevelStartWindow(
                                    levelType,
                                    tileData['level'],
                                  );
                                } else {
                                  imageAsset = 'assets/images/level_tiles/level_tile_grey.png';
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
                                    imageAsset: imageAsset,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: Text('No data found.'));
              }
            },
          ),
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
