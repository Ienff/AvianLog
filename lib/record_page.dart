import 'package:flutter/material.dart';
import 'database/database_helper.dart'; // 导入数据库助手类
import 'dart:io'; // 用于处理文件路径

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<Map<String, dynamic>> _samplePoints = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSamplePoints();
  }

  // 加载样点数据
  Future<void> _loadSamplePoints() async {
    final data = await _dbHelper.getSamplePoints();
    setState(() {
      _samplePoints = data;
    });
  }

  // 删除样点数据
  Future<void> _deleteSamplePoint(int id) async {
    await _dbHelper.deleteSamplePoint(id);
    _loadSamplePoints(); // 删除后重新加载数据
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录页面'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSamplePoints, // 点击刷新按钮时重新加载数据
          ),
        ],
      ),
      body: _samplePoints.isEmpty
          ? const Center(
        child: Text('暂无数据'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _samplePoints.length,
        itemBuilder: (context, index) {
          final samplePoint = _samplePoints[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '样点${samplePoint['id']}', // 显示样点编号
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          _deleteSamplePoint(samplePoint['id']); // 删除样点
                        },
                      ),
                    ],
                  ),
                  if (samplePoint['imagePath'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Image.file(
                        File(samplePoint['imagePath']),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Text('时间: ${samplePoint['time']}'),
                  Text('经纬度: ${samplePoint['coordinates']}'),
                  Text('鸟种: ${samplePoint['birdSpecies']}'),
                  Text('性别: ${samplePoint['gender']}'),
                  Text('数量: ${samplePoint['quantity']}'),
                  Text('生境类型: ${samplePoint['habitatType']}'),
                  Text('距样线 (cm): ${samplePoint['distanceToLine']}'),
                  Text('状态: ${samplePoint['status']}'),
                  Text('备注: ${samplePoint['remarks']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}