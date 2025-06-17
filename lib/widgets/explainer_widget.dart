import 'package:flutter/material.dart';

class ExplainerWidget extends StatelessWidget {
  final String content;
  const ExplainerWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      content,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                ),
              ),
            ),
            Divider(
              color: Colors.grey[400],
              thickness: 1,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      content,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
