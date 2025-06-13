import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kid_coder/widgets/chapter_tile.dart';
import 'package:kid_coder/widgets/level_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future getData() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/JAVA/levels_data.json',
    );
    final data = jsonDecode(jsonString);

    print(data);
    return data;
  }

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
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          print(data);
          return Column(
            children: [
              ChapterTile(title: 'chapter 1'),
              ListView.builder(
                itemBuilder: (context, index) {
                  final type = data["list of levels"][index]['levelType'];

                  return LevelTile(
                    icon:
                        type == 'explainer'
                            ? Icons.book
                            : type == 'mcq'
                            ? Icons.question_answer
                            : Icons.code,
                  );
                },

                shrinkWrap: true,
                itemCount: 3,
              ),
            ],
          );
        },
      ),
    );
  }
}
