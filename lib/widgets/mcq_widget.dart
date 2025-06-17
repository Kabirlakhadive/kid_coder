import 'package:flutter/material.dart';

class McqWidget extends StatefulWidget {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  const McqWidget({
    super.key,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  @override
  State<McqWidget> createState() => _McqWidgetState();
}

class _McqWidgetState extends State<McqWidget> {
  String? _selectedOption;
  bool _answered = false;

  void _onOptionTap(String option) {
    if (_answered) return;
    setState(() {
      _selectedOption = option;
      _answered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.question,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.options.map((option) {
                final isSelected = _selectedOption == option;
                final isCorrect = option == widget.correctAnswer;
                Color? color;
                Color borderColor = Colors.grey[400]!;
                if (_answered) {
                  if (isCorrect) {
                    color = Colors.green[300];
                    borderColor = Colors.green[700]!;
                  } else if (isSelected) {
                    color = Colors.red[300];
                    borderColor = Colors.red[700]!;
                  } else {
                    color = Colors.grey[800];
                  }
                } else {
                  color = Colors.grey[800];
                }
                return Material(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _onOptionTap(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_answered)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _selectedOption == widget.correctAnswer
                      ? 'Correct!'
                      : 'Incorrect. The correct answer is: ${widget.correctAnswer}',
                  style: TextStyle(
                    color: _selectedOption == widget.correctAnswer ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_answered && widget.explanation != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.explanation!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}