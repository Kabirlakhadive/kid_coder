import 'package:flutter/material.dart';

class CodeWidget extends StatefulWidget {
  final Map<String, dynamic> levelData;
  final Function(bool)? onAnswered;
  const CodeWidget({Key? key, required this.levelData, this.onAnswered}) : super(key: key);

  @override
  State<CodeWidget> createState() => _CodeWidgetState();
}

class _CodeWidgetState extends State<CodeWidget> {
  final TextEditingController _controller = TextEditingController();
  String? _output;
  String? _error;
  bool _checked = false;

  void _checkCode() {
    final codeQuestion = widget.levelData['questions']?.firstWhere(
      (q) => q['questionType'] == 'code',
      orElse: () => null,
    );
    if (codeQuestion == null) {
      setState(() {
        _error = 'No code question found.';
        _output = null;
        _checked = true;
      });
      if (widget.onAnswered != null) {
        widget.onAnswered!(false);
      }
      return;
    }
    final correctCode = codeQuestion['correctCode']?.trim();
    final expectedOutput = codeQuestion['expectedOutput'];
    final userCode = _controller.text.trim();
    String normalize(String s) => s.replaceAll(RegExp(r'\s+'), '');
    final isCorrect = normalize(userCode) == normalize(correctCode ?? '');
    if (isCorrect) {
      setState(() {
        _output = expectedOutput;
        _error = null;
        _checked = true;
      });
    } else {
      setState(() {
        _output = null;
        _error = 'Incorrect code. Try again!';
        _checked = true;
      });
    }
    if (widget.onAnswered != null) {
      widget.onAnswered!(isCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final codeQuestion = widget.levelData['questions']?.firstWhere(
      (q) => q['questionType'] == 'code',
      orElse: () => null,
    );
    if (codeQuestion == null) {
      return const Text('No code question available.');
    }
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              codeQuestion['content'] ?? 'Code Question',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'Type your code here',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkCode,
              child: const Text('Run'),
            ),
            const SizedBox(height: 16),
            if (_checked && _output != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.green[50],
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Output: $_output')),
                  ],
                ),
              ),
            if (_checked && _error != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red[50],
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
