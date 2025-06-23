import 'package:flutter/material.dart';

class LevelTile extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String imageAsset;
  const LevelTile({
    super.key,
    required this.icon,
    required this.onTap,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 72,
        width: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
              ),
            ),
            // Icon overlay
            Icon(
              icon,
              color: Colors.white,
              size: 32,
              shadows: [
                BoxShadow(
                  color: Colors.grey[400]!,
                  offset: const Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
