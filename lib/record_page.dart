import 'package:flutter/material.dart';
import 'database/database_helper.dart'; // 导入数据库助手类

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  // 定义存储样点数据的列表
  List<Map<String, dynamic>> _samplePoints = [];

  // 定义数据库助手实例
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    // 初始化时加载数据
    _loadSamplePoints();
  }

  // 从数据库加载样点数据
  Future<void> _loadSamplePoints() async {
    final data = await _dbHelper.getSamplePoints();
    setState(() {
      _samplePoints = data;
    });
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