import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'teacher_detail_page.dart';
import 'package:smartify/pages/api_server/api_server.dart';
import '../nav/nav_page.dart';
import 'package:smartify/l10n/app_localizations.dart';


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
    final String jsonString = await TeacherMeneger.loadTeachers();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    setState(() {
      _allTeachers = jsonList.cast<Map<String, dynamic>>();
      _loading = false;
    });
  }

  String _translateSubject(String subject) {
    final localizations = AppLocalizations.of(context)!;
    switch (subject) {
      case 'Математика':
        return localizations.subjectMath;
      case 'Физика':
        return localizations.subjectPhysics;
      case 'Химия':
        return localizations.subjectChemistry;
      case 'Биология':
        return localizations.subjectBiology;
      case 'Русский язык':
        return localizations.subjectRussianLang;
      case 'Литература':
        return localizations.subjectLiterature;
      case 'История':
        return localizations.subjectHistory;
      case 'Обществознание':
        return localizations.subjectSocialStudies;
      case 'Информатика':
        return localizations.subjectInformatics;
      case 'Английский язык':
        return localizations.subjectEnglishLang;
      case 'География':
        return localizations.subjectGeography;
      case 'Немецкий язык':
        return localizations.subjectGermanLang;
      case 'Французский язык':
        return localizations.subjectFrenchLang;
      case 'Испанский язык':
        return localizations.subjectSpanishLang;
      case 'Музыка':
        return localizations.subjectMusic;
      case 'Рисование':
        return localizations.subjectDrawing;
      case 'Китайский язык':
        return localizations.subjectChineseLang;
      default:
        return subject;
    }
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

  List<String> get _priceRanges {
    final localizations = AppLocalizations.of(context)!;
    return [
      localizations.priceLessThan1000,
      localizations.price1000to2000,
      localizations.price2000to3000,
      localizations.priceMoreThan3000,
    ];
  }

  List<Map<String, dynamic>> get _filteredTeachers {
    return _allTeachers.where((t) {
      final subjectMatch = _selectedSubject == null || t['subject'] == _selectedSubject;
      final rating = double.tryParse(t['rating']?.toString() ?? '0') ?? 0;
      final ratingMatch = _selectedRating == null || rating >= _selectedRating!;
      final price = int.tryParse(t['price']?.toString() ?? '') ?? 0;
      bool priceMatch = true;
      if (_selectedPriceRange != null) {
        final localizations = AppLocalizations.of(context)!;
        if (_selectedPriceRange == localizations.priceLessThan1000) {
          priceMatch = price < 1000;
        } else if (_selectedPriceRange == localizations.price1000to2000) {
          priceMatch = price >= 1000 && price <= 2000;
        } else if (_selectedPriceRange == localizations.price2000to3000) {
          priceMatch = price > 2000 && price <= 3000;
        } else if (_selectedPriceRange == localizations.priceMoreThan3000) {
          priceMatch = price > 3000;
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
          title: Text(AppLocalizations.of(context)!.minRating, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              child: Text(AppLocalizations.of(context)!.cancel),
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
              child: Text(AppLocalizations.of(context)!.apply),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.tutors,
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Color(0xFF54D0C0) : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
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
                        text: AppLocalizations.of(context)!.subject,
                        value: _selectedSubject == null ? null : _translateSubject(_selectedSubject!),
                        onTap: () => _showFilterDialog(AppLocalizations.of(context)!.subject, _subjects, _selectedSubject, (val) => setState(() => _selectedSubject = val)),
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        text: AppLocalizations.of(context)!.rating,
                        value: _selectedRating == null ? null : _selectedRating!.toStringAsFixed(1),
                        onTap: _showRatingSliderDialog,
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        text: AppLocalizations.of(context)!.price,
                        value: _selectedPriceRange,
                        onTap: () => _showFilterDialog(AppLocalizations.of(context)!.price, _priceRanges, _selectedPriceRange, (val) => setState(() => _selectedPriceRange = val)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredTeachers.length,
                    itemBuilder: (context, index) {
                      final teacher = _filteredTeachers[index];
                      final avatar = (teacher['avatarurl']?.toString() ?? '').isNotEmpty
                        ? teacher['avatarurl'].toString()
                        : 'assets/user_avatar.jpg';
                      return _TeacherCard(
                        name: teacher['name'] ?? '',
                        subject: _translateSubject(teacher['subject'] ?? ''),
                        experience: teacher['level'] ?? '',
                        rating: teacher['rating']?.toString() ?? '',
                        price: teacher['price']?.toString() ?? '',
                        avatar: avatar,
                        onDetail: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeacherDetailPage(teacher: teacher),
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
              child: Text(AppLocalizations.of(context)!.all),
              onPressed: () => Navigator.pop(context, null),
            ),
            ...items.map((item) => SimpleDialogOption(
                  child: Text(_translateSubject(item)),
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
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
            radius: 28,
            backgroundColor: theme.scaffoldBackgroundColor,
            child: ClipOval(
              child: avatar.startsWith('http') || avatar.startsWith('https')
                  ? Image.network(
                      avatar,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      errorBuilder: (context, error, stackTrace) => Image.asset('assets/user_avatar.jpg', fit: BoxFit.cover, width: 56, height: 56),
                    )
                  : Image.asset(
                      avatar,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      errorBuilder: (context, error, stackTrace) => Image.asset('assets/user_avatar.jpg', fit: BoxFit.cover, width: 56, height: 56),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(subject, style: theme.textTheme.bodyMedium),
                Text('${AppLocalizations.of(context)!.experience}: $experience', style: theme.textTheme.bodySmall),
                Row(
                  children: [
                    Text('${AppLocalizations.of(context)!.ratingLabel}: $rating', style: theme.textTheme.bodySmall),
                    const SizedBox(width: 2),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                  ],
                ),
                Text('${AppLocalizations.of(context)!.priceLabel}: $price ₽', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.15),
              foregroundColor: theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            onPressed: onDetail,
            child: Text(AppLocalizations.of(context)!.details),
          ),
        ],
      ),
    );
  }
} 