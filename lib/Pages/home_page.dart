import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kid_coder/Pages/level_page.dart';
import 'package:kid_coder/widgets/chapter_tile.dart';
import 'package:kid_coder/widgets/level_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // BEST PRACTICE: Store the future in a state variable.
  late Future<Map<String, dynamic>> _mapDataFuture;

  @override
  void initState() {
    super.initState();
    // Call getData() only ONCE when the widget is first created.
    _mapDataFuture = _loadMapData();
  }

  Future<Map<String, dynamic>> _loadMapData() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/JAVA/map_data.json',
    );
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    // print(data);
    return data;
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
      body: FutureBuilder<Map<String, dynamic>>(
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
            final data = snapshot.data!;

            final tiles = data['ListOfTiles'] as List;

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

                      return Align(
                        alignment: Alignment(alignmentX, 0),
                        child: LevelTile(
                          icon:
                              levelType == 'explainer'
                                  ? Icons.book
                                  : levelType == 'mcq'
                                  ? Icons.help_outline_rounded
                                  : Icons.code,

                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => LevelPage(
                                        levelType: levelType,
                                        level: tileData['level'],
                                      ),
                                ),
                              ),

                          color:
                              color == "blue"
                                  ? Colors.blue
                                  : color == "green"
                                  ? Colors.green
                                  : Colors.red,

                          shadowColor:
                              color == "blue"
                                  ? Colors.blue[800]!
                                  : color == "green"
                                  ? Colors.green[800]!
                                  : Colors.red[800]!,
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
    );
  }
}
