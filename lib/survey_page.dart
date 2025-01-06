import 'package:flutter/material.dart';

class SurveyPage extends StatelessWidget {
  const SurveyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 保持底部导航栏的功能
      body: Column(
        children: [
          // 地图占位（边缘弧形的正方形）
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
          // 新建样点按钮
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
                      sampleLine: 1,
                      samplePoint: 1,
                      initialTime: formattedTime,
                      initialCoordinates: coordinates,
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
  final int sampleLine;
  final int samplePoint;
  final String initialTime; // 初始时间
  final String initialCoordinates; // 初始经纬度

  const SamplePointPage({
    super.key,
    required this.sampleLine,
    required this.samplePoint,
    required this.initialTime,
    required this.initialCoordinates,
  });

  @override
  _SamplePointPageState createState() => _SamplePointPageState();
}

class _SamplePointPageState extends State<SamplePointPage> {
  // 定义“幼鸟”复选框的状态
  bool _isYoungBird = false;

  // 定义“性别”单选按钮的状态
  String? _gender; // 'female' 或 'male'

  // 定义时间输入框的控制器
  final TextEditingController _timeController = TextEditingController();
  // 定义经纬度输入框的控制器
  final TextEditingController _coordinatesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化时间和经纬度
    _timeController.text = widget.initialTime;
    _coordinatesController.text = widget.initialCoordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('样线${widget.sampleLine}，样点${widget.samplePoint}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // 保存数据并返回主界面
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField('时间 (YYYY-MM-DD)', controller: _timeController),
                  _buildTextField('经纬度 (A, B)', controller: _coordinatesController),
                  _buildTextField('鸟种'),
                  _buildGenderRadio(), // 替换为性别单选按钮
                  _buildTextField('数量'),
                  _buildTextField('生境类型'),
                  _buildTextField('距样线 (cm)'),
                  _buildTextField('状态'),
                  _buildTextField('备注', maxLines: 3),
                ],
              ),
            ),
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
}