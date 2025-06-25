import 'package:flutter/material.dart';
import 'package:kid_coder/widgets/chapter_title_tile.dart';

class ChaptersPage extends StatelessWidget {
  const ChaptersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: 
    ListView.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return ChapterTitleTile(title: 'Chapter $index', chapterNumber: index, color: Colors.blue);
      },
    ),);
  }
}
