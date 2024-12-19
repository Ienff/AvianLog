import 'package:flutter/material.dart';
import 'dart:math'; // 用于生成随机文字

class EncyclopediaPage extends StatefulWidget {
  const EncyclopediaPage({super.key});

  @override
  State<EncyclopediaPage> createState() => _EncyclopediaPageState();
}

class _EncyclopediaPageState extends State<EncyclopediaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _speciesName = ''; // Storing the name of the species
  String _speciesDescription = ''; // Storing the description of the species
  String _speciesImageUrl = ''; // Storing the image URL of the species

  // Simulate fetching species data from an API
  void _fetchSpeciesData(String speciesName) {
    // Simulate a network request delay
    setState(() {
      _speciesName = speciesName;
      _speciesDescription = _generateRandomDescription(); // 生成随机描述
      _speciesImageUrl = 'https://via.placeholder.com/200'; // 使用空白图片占位符
    });
  }

  // 生成随机描述
  String _generateRandomDescription() {
    const List<String> descriptions = [
      '这是一种非常稀有的物种，生活在热带雨林中。',
      '该物种以其鲜艳的颜色和独特的形态而闻名。',
      '这种生物是食草动物，主要以树叶为食。',
      '它是一种夜行动物，白天通常躲在树洞中休息。',
      '该物种在全球范围内受到保护，禁止捕猎。',
    ];
    final random = Random();
    return descriptions[random.nextInt(descriptions.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '请输入物种名称',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
          onPressed: () {
            final speciesName = _searchController.text;
            if (speciesName.isNotEmpty) {
              _fetchSpeciesData(speciesName); // Get species data
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
          ),
          child: const Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            if (_speciesName.isNotEmpty) ...[
              Text(
              '物种名称: $_speciesName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
              child: Image.network(
                _speciesImageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              ),
              const SizedBox(height: 16),
              Text(
              '物种描述: $_speciesDescription',
              style: const TextStyle(fontSize: 16),
              ),
            ] else
              const Center(
              child: Text(
                '请输入物种名称以查看百科内容。',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              ),
            ],
        ),
      ),
    );
  }
}