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
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey,
              thickness: 1,
              endIndent: 10,
            ),
          ),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 10,
            ),
          ),
        ],
      ),
    );
  }
}
