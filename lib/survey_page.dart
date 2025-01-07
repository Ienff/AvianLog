import 'dart:io';
import 'package:flutter/material.dart';
import 'database/database_helper.dart'; // 导入数据库助手类
import 'package:image_picker/image_picker.dart'; // 导入图片选择器

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.blue[100],
                  child: const Center(
                    child: Text(
                      '地图区域',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // 获取当前时间
                final currentTime = DateTime.now();
                final formattedTime =
                    "${currentTime.year}-${currentTime.month.toString().padLeft(2, '0')}-${currentTime.day.toString().padLeft(2, '0')}";

                // 模拟经纬度数据
                const latitude = 39.9042; // 纬度
                const longitude = 116.4074; // 经度
                const coordinates = '$latitude, $longitude';

                // 跳转到样点界面，并传递时间和经纬度
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SamplePointPage(
                      initialTime: formattedTime,
                      initialCoordinates: coordinates,
                      onSave: () {
                        // 保存成功后的回调
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.flag),
              label: const Text('新建样点'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class SamplePointPage extends StatefulWidget {
  final String initialTime; // 初始时间
  final String initialCoordinates; // 初始经纬度
  final VoidCallback onSave; // 保存后的回调函数

  const SamplePointPage({
    super.key,
    required this.initialTime,
    required this.initialCoordinates,
    required this.onSave,
  });

  @override
  _SamplePointPageState createState() => _SamplePointPageState();
}

class _SamplePointPageState extends State<SamplePointPage> {
  String? _gender; // 'female' 或 'male'
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _coordinatesController = TextEditingController();
  final TextEditingController _birdSpeciesController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _habitatTypeController = TextEditingController();
  final TextEditingController _distanceToLineController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  String? _imagePath; // 存储图片路径

  @override
  void initState() {
    super.initState();
    // 初始化时间和经纬度
    _timeController.text = widget.initialTime;
    _coordinatesController.text = widget.initialCoordinates;
  }

  // 拍照功能
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建样点'), // 直接显示“新建样点”
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSamplePoint, // 点击保存按钮时调用保存方法
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 拍照按钮
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('拍照'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              // 显示拍摄的图片
              if (_imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Image.file(
                    File(_imagePath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField('时间 (YYYY-MM-DD)', controller: _timeController),
                      _buildTextField('经纬度 (A, B)', controller: _coordinatesController),
                      _buildTextField('鸟种', controller: _birdSpeciesController),
                      _buildGenderRadio(), // 替换为性别单选按钮
                      _buildTextField('数量', controller: _quantityController),
                      _buildTextField('生境类型', controller: _habitatTypeController),
                      _buildTextField('距样线 (cm)', controller: _distanceToLineController),
                      _buildTextField('状态', controller: _statusController),
                      _buildTextField('备注', controller: _remarksController, maxLines: 3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建输入框
  Widget _buildTextField(String label, {int maxLines = 1, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
      ),
    );
  }

  // 构建性别单选按钮
  Widget _buildGenderRadio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '性别',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Row(
            children: [
              Radio<String>(
                value: 'female',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              const Text('雌性'),
              const SizedBox(width: 20),
              Radio<String>(
                value: 'male',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              const Text('雄性'),
              const SizedBox(width: 20),
              Radio<String>(
                value: 'unknown',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              const Text('未知'),
            ],
          ),
        ],
      ),
    );
  }

  // 保存样点数据
  Future<void> _saveSamplePoint() async {
    // 构造样点数据
    final samplePoint = {
      'time': _timeController.text,
      'coordinates': _coordinatesController.text,
      'birdSpecies': _birdSpeciesController.text,
      'gender': _gender,
      'quantity': int.tryParse(_quantityController.text) ?? 0,
      'habitatType': _habitatTypeController.text,
      'distanceToLine': int.tryParse(_distanceToLineController.text) ?? 0,
      'status': _statusController.text,
      'remarks': _remarksController.text,
      'imagePath': _imagePath, // 保存图片路径
    };

    // 插入数据到数据库
    final dbHelper = DatabaseHelper();
    await dbHelper.insertSamplePoint(samplePoint);

    // 调用回调函数
    widget.onSave();

    // 返回主界面
    if (mounted) {
      Navigator.pop(context);
    }
  }
}