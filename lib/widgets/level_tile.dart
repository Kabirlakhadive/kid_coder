import 'package:flutter/material.dart';

class LevelTile extends StatelessWidget {
  final Color shadowColor;
  final Color color;
  final VoidCallback onTap;
  final IconData icon;
  const LevelTile({
    super.key,
    required this.icon,
    required this.onTap,
    required this.color,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
          shadows: [
            BoxShadow(
              color: Colors.grey[400]!,
              offset: const Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}
