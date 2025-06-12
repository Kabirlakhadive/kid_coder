import 'package:flutter/material.dart';
import 'package:kid_coder/widgets/chapter_tile.dart';
import 'package:kid_coder/widgets/level_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Colors.transparent,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Homepage'),
      ),
      body: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(child: ChapterTile(title: 'Chapter 1')),
          Center(child: LevelTile(title: 'title', icon: Icons.book)),
          Center(child: LevelTile(title: 'title', icon: Icons.book)),
        ],
      ),
    );
  }
}
