import 'package:flutter/material.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录页面'),
      ),
      body: const Center(
        child: Text('这里是记录页面的内容'),
      ),
    );
  }
}