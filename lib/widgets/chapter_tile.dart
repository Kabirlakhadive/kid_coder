import 'package:flutter/material.dart';

class ChapterTile extends StatelessWidget {
  final String title;
  const ChapterTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[400],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[800]!,
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(child: Text(title)),
    );
  }
}
