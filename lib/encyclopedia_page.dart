import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EncyclopediaPage extends StatefulWidget {
  const EncyclopediaPage({super.key});

  @override
  State<EncyclopediaPage> createState() => _EncyclopediaPageState();
}

class _EncyclopediaPageState extends State<EncyclopediaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _speciesName = '';
  List<Map<String, String>> _speciesDescriptions = []; // 用于存储多个描述类型的内容

  // Fetch species data from the Chinese Animal Database API
  Future<void> _fetchSpeciesData(String speciesName) async {
    const apiKey = 'fd579f2d16ae44448cd043201fa7a7d2';
    const databaseName = '中国鸟类数据库'; // 默认使用第一个数据库

    // 更新界面，清空之前的描述信息
    setState(() {
      _speciesName = speciesName;
      _speciesDescriptions.clear();
    });

    // Step 1: Fetch description type information
    final descriptionTypeUrl = Uri.parse(
        'http://zoology.especies.cn/api/v1/descriptionType?scientificName=$speciesName&dbaseName=$databaseName&apiKey=$apiKey');
    final descriptionTypeResponse = await http.post(descriptionTypeUrl);

    if (descriptionTypeResponse.statusCode == 200) {
      final descriptionTypeData = json.decode(descriptionTypeResponse.body);
      if (descriptionTypeData['code'] == 200) {
        final desTypes = descriptionTypeData['data']['desType'];
        if (desTypes.isNotEmpty) {
          // 遍历所有描述类型并获取描述信息
          for (var desType in desTypes) {
            final desTypeId = desType.keys.first; // 动态获取描述类型 ID
            final desTypeName = desType.values.first; // 动态获取描述类型名称
            await _fetchDescription(speciesName, desTypeId, desTypeName);
            print('Fetching description for $desTypeName');
          }
        } else {
          _updateState('没有找到相关描述类型');
        }
      } else {
        _updateState(descriptionTypeData['message'] ?? '无法获取描述类型信息');
      }
    } else {
      _updateState('网络请求失败，无法获取描述类型信息');
    }
  }

  // Step 2: Fetch species description
  Future<void> _fetchDescription(String speciesName, String descriptionType, String desTypeName) async {
    const apiKey = 'fd579f2d16ae44448cd043201fa7a7d2';
    const databaseName = '中国鸟类数据库';
    final descriptionUrl = Uri.parse(
        'http://zoology.especies.cn/api/v1/description?scientificName=$speciesName&dbaseName=$databaseName&descriptionType=$descriptionType&apiKey=$apiKey');
    final descriptionResponse = await http.post(descriptionUrl);

    if (descriptionResponse.statusCode == 200) {
      final descriptionData = json.decode(descriptionResponse.body);
      print(descriptionData);
      if (descriptionData['code'] == 200) {
        final descriptionInfo = descriptionData['data']['DescriptionInfo'];
        if (descriptionInfo.isNotEmpty) {
          final description = descriptionInfo[0]['descontent'] ?? '没有描述内容';
          // 将描述信息添加到列表中
          setState(() {
            _speciesDescriptions.add({
              'type': desTypeName,
              'content': description.replaceAll('<br>', '\n'), // 替换 <br> 为换行符
            });
          });
        } else {
          _updateState('没有找到相关描述内容');
        }
      } else {
        _updateState(descriptionData['message'] ?? '无法获取描述信息');
      }
    } else {
      _updateState('网络请求失败，无法获取描述信息');
    }
  }

  // Update UI state
  void _updateState(String message) {
    setState(() {
      _speciesDescriptions.add({
        'type': '错误',
        'content': message,
      });
    });
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
                    _fetchSpeciesData(speciesName);
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
              if (_speciesDescriptions.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _speciesDescriptions.length,
                    itemBuilder: (context, index) {
                      final description = _speciesDescriptions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${description['type']}', // 描述类型
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${description['content']}', // 描述内容
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                const Text(
                  '没有找到相关描述内容',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
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