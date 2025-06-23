import 'package:flutter/material.dart';

class ChapterTitleTile extends StatelessWidget {
  final int chapterNumber;
  final String title;
  final Color color;
  const ChapterTitleTile({
    super.key,
    required this.chapterNumber,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        'Chapter $chapterNumber: $title',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
