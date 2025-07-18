import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'teacher_detail_page.dart';
import 'package:smartify/pages/api_server/api_server.dart';
import '../nav/nav_page.dart';


class TeachersListPage extends StatefulWidget {
  const TeachersListPage({Key? key}) : super(key: key);

  @override
  State<TeachersListPage> createState() => _TeachersListPageState();
}

class _TeachersListPageState extends State<TeachersListPage> {
  List<Map<String, dynamic>> _allTeachers = [];
  String? _selectedSubject;
  double? _selectedRating; // теперь double
  String? _selectedPriceRange;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    TeacherMeneger.UpdateTeachers();
    //final String jsonString = await rootBundle.loadString('assets/teachers.json');
    final String jsonString = await TeacherMeneger.loadSavedJsonTeachers();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    setState(() {
      _allTeachers = jsonList.cast<Map<String, dynamic>>();
      _loading = false;
    });
  }

  List<String> get _subjects => _allTeachers.map((t) => t['subject'] as String).toSet().toList();
  List<double> get _ratings {
    final ratings = _allTeachers
        .map((t) => double.tryParse(t['rating']?.toString() ?? '0') ?? 0)
        .toSet()
        .toList();
    ratings.sort((a, b) => b.compareTo(a));
    return ratings;
  }
  final List<String> _priceRanges = [
    'Меньше 1000',
    '1000–2000',
    '2000–3000',
    'Больше 3000',
  ];

  List<Map<String, dynamic>> get _filteredTeachers {
    return _allTeachers.where((t) {
      final subjectMatch = _selectedSubject == null || t['subject'] == _selectedSubject;
      final rating = double.tryParse(t['rating']?.toString() ?? '0') ?? 0;
      final ratingMatch = _selectedRating == null || rating >= _selectedRating!;
      final price = int.tryParse(t['price']?.toString() ?? '') ?? 0;
      bool priceMatch = true;
      if (_selectedPriceRange != null) {
        switch (_selectedPriceRange) {
          case 'Меньше 1000':
            priceMatch = price < 1000;
            break;
          case '1000–2000':
            priceMatch = price >= 1000 && price <= 2000;
            break;
          case '2000–3000':
            priceMatch = price > 2000 && price <= 3000;
            break;
          case 'Больше 3000':
            priceMatch = price > 3000;
            break;
        }
      }
      return subjectMatch && ratingMatch && priceMatch;
    }).toList();
  }

  void _showRatingSliderDialog() {
    final ratings = _ratings;
    final min = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a < b ? a : b);
    final max = ratings.isEmpty ? 5.0 : ratings.reduce((a, b) => a > b ? a : b);
    double value = _selectedRating ?? min;
    double step = 0.1;
    showDialog(
      context: context,
      builder: (context) {
        double tempValue = value;
        return AlertDialog(
          title: const Text('Минимальный рейтинг', style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SizedBox(
                width: 280,
                height: 80,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Slider(
                        value: tempValue,
                        min: min,
                        max: max,
                        divisions: ((max - min) ~/ step).toInt(),
                        label: tempValue.toStringAsFixed(1),
                        activeColor: const Color(0xFF4CAF50),
                        onChanged: (val) {
                          setStateDialog(() {
                            tempValue = double.parse(val.toStringAsFixed(1));
                            if (tempValue > max) tempValue = max;
                            if (tempValue < min) tempValue = min;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        tempValue.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedRating = tempValue);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: const Text('Применить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardPage()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Репетиторы',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _FilterButton(
                        text: 'Предмет',
                        value: _selectedSubject,
                        onTap: () => _showFilterDialog('Предмет', _subjects, _selectedSubject, (val) => setState(() => _selectedSubject = val)),
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        text: 'Рейтинг',
                        value: _selectedRating == null ? null : _selectedRating!.toStringAsFixed(1),
                        onTap: _showRatingSliderDialog,
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        text: 'Цена',
                        value: _selectedPriceRange,
                        onTap: () => _showFilterDialog('Цена', _priceRanges, _selectedPriceRange, (val) => setState(() => _selectedPriceRange = val)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredTeachers.length,
                    itemBuilder: (context, index) {
                      final teacher = _filteredTeachers[index];
                      return _TeacherCard(
                        name: teacher['name'] ?? '',
                        subject: teacher['subject'] ?? '',
                        experience: teacher['level'] ?? '',
                        rating: teacher['rating']?.toString() ?? '',
                        price: teacher['price']?.toString() ?? '',
                        avatar: 'assets/user_avatar.jpg',
                        onDetail: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeacherDetailPage(teacher: teacher),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _showFilterDialog(String label, List<String> items, String? selected, ValueChanged<String?> onChanged) async {
    String? result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(label),
          children: [
            SimpleDialogOption(
              child: const Text('Все'),
              onPressed: () => Navigator.pop(context, null),
            ),
            ...items.map((item) => SimpleDialogOption(
                  child: Text(item),
                  onPressed: () => Navigator.pop(context, item),
                )),
          ],
        );
      },
    );
    onChanged(result);
  }
}

class _FilterButton extends StatelessWidget {
  final String text;
  final String? value;
  final VoidCallback onTap;
  const _FilterButton({required this.text, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F1ED),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value == null ? text : value!,
                  style: const TextStyle(color: Color(0xFF3B6C5A), fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFF3B6C5A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final String name, subject, experience, rating, price, avatar;
  final VoidCallback onDetail;
  const _TeacherCard({
    required this.name,
    required this.subject,
    required this.experience,
    required this.rating,
    required this.price,
    required this.avatar,
    required this.onDetail,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(avatar),
            radius: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subject, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                Text('Стаж: $experience', style: const TextStyle(fontSize: 12)),
                Row(
                  children: [
                    Text('Рейтинг: $rating', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 2),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                  ],
                ),
                Text('Цена: $price ₽', style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3F1ED),
              foregroundColor: const Color(0xFF3B6C5A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            onPressed: onDetail,
            child: const Text('Подробнее'),
          ),
        ],
      ),
    );
  }
} 