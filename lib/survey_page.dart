import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'database/database_helper.dart';

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
                final currentTime = DateTime.now();
                final formattedTime =
                    "${currentTime.year}-${currentTime.month.toString().padLeft(2, '0')}-${currentTime.day.toString().padLeft(2, '0')}";

                const latitude = 39.9042;
                const longitude = 116.4074;
                const coordinates = '$latitude, $longitude';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SamplePointPage(
                      initialTime: formattedTime,
                      initialCoordinates: coordinates,
                      onSave: () {},
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
  final String initialTime;
  final String initialCoordinates;
  final VoidCallback onSave;

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
  String? _gender;
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _coordinatesController = TextEditingController();
  final TextEditingController _birdSpeciesController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _habitatTypeController = TextEditingController();
  final TextEditingController _distanceToLineController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _timeController.text = widget.initialTime;
    _coordinatesController.text = widget.initialCoordinates;
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });

      // 调用百度动物识别 API
      final speciesName = await _recognizeAnimal(pickedFile.path);
      if (speciesName != null) {
        _birdSpeciesController.text = speciesName;
      } else {
        print('未能识别到物种信息');
      }
    }
  }

  Future<String?> _recognizeAnimal(String imagePath) async {
    final apiKey = 'ZD3RgiDY7RncuChAJljJRyfE';
    final secretKey = 'b79d61b4TEFUZ9mQlHj95tiRGs99TgYK';
    final accessToken = await _getAccessToken(apiKey, secretKey);

    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    print('Base64 图片数据: ${base64Image.substring(0, 50)}...'); // 输出部分 Base64 数据

    final url = Uri.parse('https://aip.baidubce.com/rest/2.0/image-classify/v1/animal?access_token=$accessToken');
    print('请求 URL: $url');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'image': base64Image, 'baike_num': '1'},
    );

    print('API 响应状态码: ${response.statusCode}');
    print('API 响应体: ${response.body}');

    if (response.statusCode == 200) {
      // 手动将响应体解码为 UTF-8
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['result'] != null && jsonResponse['result'].isNotEmpty) {
        final result = jsonResponse['result'][0];
        print('识别结果: ${result['name']} (置信度: ${result['score']})');
        return result['name'];
      } else {
        print('未识别到任何物种');
      }
    } else {
      print('API 请求失败: ${response.statusCode}');
    }
    return null;
  }

  Future<String> _getAccessToken(String apiKey, String secretKey) async {
    final url = Uri.parse('https://aip.baidubce.com/oauth/2.0/token');
    print('获取 Access Token 的 URL: $url');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'client_credentials',
        'client_id': apiKey,
        'client_secret': secretKey,
      },
    );

    print('Access Token 响应状态码: ${response.statusCode}');
    print('Access Token 响应体: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['access_token'];
    } else {
      throw Exception('获取 Access Token 失败: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建样点'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSamplePoint,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                      _buildGenderRadio(),
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

  Future<void> _saveSamplePoint() async {
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
      'imagePath': _imagePath,
    };

    final dbHelper = DatabaseHelper();
    await dbHelper.insertSamplePoint(samplePoint);

    widget.onSave();

    if (mounted) {
      Navigator.pop(context);
    }
  }
}