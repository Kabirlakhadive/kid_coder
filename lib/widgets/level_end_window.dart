import 'package:flutter/material.dart';
import 'button_widget.dart';

class LevelEndWindow extends StatelessWidget {
  final VoidCallback onClose;
  const LevelEndWindow({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Level Complete!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Congratulations! You have finished this level.',
              style: TextStyle(fontSize: 15, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ButtonWidget(
              color: Colors.green,
              text: 'Close',
              shadowColor: Colors.green[800]!,
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
