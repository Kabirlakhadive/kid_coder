import 'package:flutter/material.dart';

class LevelTile extends StatelessWidget {
  final IconData icon;
  const LevelTile({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue[400],
        boxShadow: [
          BoxShadow(
            color: Colors.blue[800]!,
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),

      child: Icon(icon, color: Colors.white, size: 40),
    );
  }
}
