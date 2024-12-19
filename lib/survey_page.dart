import 'package:flutter/material.dart';

class SurveyPage extends StatelessWidget {
  const SurveyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('调查页面'),
      ),
      body: const Center(
        child: Text('这里是调查页面的内容'),
      ),
    );
  }
}