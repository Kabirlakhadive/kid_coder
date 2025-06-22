import 'package:flutter/material.dart';

class ArrangeWidget extends StatefulWidget {
  final String prompt;
  final List<String> tokens;
  final List<String> correctOrder;
  final String? explanation;
  final VoidCallback? onAnswered;
  const ArrangeWidget({
    super.key,
    required this.prompt,
    required this.tokens,
    required this.correctOrder,
    this.explanation,
    this.onAnswered,
  });

  @override
  State<ArrangeWidget> createState() => _ArrangeWidgetState();
}

class _ArrangeWidgetState extends State<ArrangeWidget> with TickerProviderStateMixin {
  late List<String> _availableTokens;
  List<String> _answerTokens = [];
  bool _answered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _availableTokens = List<String>.from(widget.tokens);
  }

  void _onTokenTap(String token) {
    if (_answered) return;
    setState(() {
      _availableTokens.remove(token);
      _answerTokens.add(token);
    });
  }

  void _onAnswerTokenTap(String token) {
    if (_answered) return;
    setState(() {
      _answerTokens.remove(token);
      _availableTokens.add(token);
    });
  }

  void _onSubmit() {
    setState(() {
      _answered = true;
      _isCorrect = _answerTokens.length == widget.correctOrder.length &&
          List.generate(_answerTokens.length, (i) => _answerTokens[i] == widget.correctOrder[i]).every((e) => e);
      if (widget.onAnswered != null) widget.onAnswered!();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
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
                    widget.prompt,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            // Answer line
            Container(
              constraints: const BoxConstraints(minHeight: 80, maxHeight: 180),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[400]!, width: 1.8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: _answerTokens.isEmpty
                    ? const Text(
                        'Tap tokens below to build your answer',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _answerTokens.map((token) => AnimatedScale(
                              scale: 1.1,
                              duration: const Duration(milliseconds: 150),
                              child: GestureDetector(
                                onTap: () => _onAnswerTokenTap(token),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[200],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.blue[700]!, width: 1.5),
                                  ),
                                  child: Text(
                                    token,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            )).toList(),
                      ),
              ),
            ),
            // Token tiles
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableTokens.map((token) => AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 1500),
                    child: Material(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _onTokenTap(token),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[400]!, width: 1.8),
                          ),
                          child: Text(
                            token,
                            style: const TextStyle(fontSize: 17, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ))
                  .toList(),
            ),
            // Submit button
            if (!_answered)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: _answerTokens.isNotEmpty ? _onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ),
            if (_answered)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _isCorrect ? 'Correct!' : 'Incorrect. The correct answer is: ${widget.correctOrder.join(' ')}',
                  style: TextStyle(
                    color: _isCorrect ? Colors.green : Colors.red,
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
