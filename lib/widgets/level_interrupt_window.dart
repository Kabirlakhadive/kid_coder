import 'package:flutter/material.dart';
import 'button_widget.dart';

class LevelInterruptWindow extends StatelessWidget {
  final VoidCallback onExit;
  final VoidCallback onCancel;
  const LevelInterruptWindow({super.key, required this.onExit, required this.onCancel});

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
              'Are you sure?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'All your progress in this level will be lost.',
              style: TextStyle(fontSize: 15, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ButtonWidget(
                    color: Colors.grey[700]!,
                    text: 'Cancel',
                    shadowColor: Colors.grey[900]!,
                    onPressed: onCancel,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ButtonWidget(
                    color: Colors.red,
                    text: 'Exit',
                    shadowColor: Colors.red[800]!,
                    onPressed: onExit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
