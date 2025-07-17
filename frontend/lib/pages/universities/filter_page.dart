import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:smartify/pages/universities/filter.dart';

class UniversityFilterPage extends StatefulWidget {
  final UniversityFilter? currentFilter;

  const UniversityFilterPage({super.key, this.currentFilter});

  @override
  State<UniversityFilterPage> createState() => _UniversityFilterPageState();
}

class _UniversityFilterPageState extends State<UniversityFilterPage> {
  List<String> allRegions = [];
  final List<String> allFaculties = ['ИТ', 'Экономика', 'Медицина'];

  List<String> selectedRegions = [];
  List<String> selectedFaculties = [];

  double minRating = 0.0;
  double budgetPlaces = 0.0;

  bool hasDorm = false;
  bool hasMilitary = false;

  final GlobalKey regionKey = GlobalKey();
  final GlobalKey facultiesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadRegions();
    final filter = widget.currentFilter;
    if (filter != null) {
      selectedRegions = List.from(filter.regions);
      selectedFaculties = List.from(filter.faculties);
      minRating = filter.minRating;
      budgetPlaces = filter.budgetPlaces;
      hasDorm = filter.hasDorm;
      hasMilitary = filter.hasMilitary;
    }
  }

  Future<void> _loadRegions() async {
    final String jsonString = await rootBundle.loadString('assets/universities.json');
    final List data = json.decode(jsonString);
    final Set<String> regions = {};
    for (final uni in data) {
      if (uni['город'] != null && uni['город'].toString().trim().isNotEmpty) {
        regions.add(uni['город'].toString().trim());
      }
    }
    setState(() {
      allRegions = regions.toList()..sort();
    });
  }

  void clearFilters() {
    setState(() {
      selectedRegions = [];
      selectedFaculties = [];
      minRating = 0.0;
      budgetPlaces = 0.0;
      hasDorm = false;
      hasMilitary = false;
    });
  }

  void applyFilters() {
    final newFilter = UniversityFilter(
      regions: selectedRegions,
      minRating: minRating,
      budgetPlaces: budgetPlaces,
      hasDorm: hasDorm,
      hasMilitary: hasMilitary,
      faculties: selectedFaculties,
    );
    Navigator.pop(context, newFilter);
  }

  void showOptionsPopup(List<String> options, List<String> selected, Function(List<String>) onChanged, GlobalKey key) async {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    List<String> tempSelected = List.from(selected);

    final selectedOption = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height,
        position.dx + renderBox.size.width,
        0,
      ),
      items: options.map((option) {
        final isSelected = tempSelected.contains(option);
        return CheckedPopupMenuItem<String>(
          value: option,
          checked: isSelected,
          child: Text(option),
        );
      }).toList(),
    );

    if (selectedOption != null) {
      setState(() {
        if (tempSelected.contains(selectedOption)) {
          tempSelected.remove(selectedOption);
        } else {
          tempSelected.add(selectedOption);
        }
        onChanged(tempSelected);
      });
    }
  }

  void showSliderDialog(String title, double value, double max, Function(double) onChanged, {int step = 1}) {
  double tempValue = value;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SizedBox(
              width: 280,
              height: 80, // ограничиваем высоту
              child: Row(
                mainAxisSize: MainAxisSize.min, // чтобы Row не растягивался по высоте
                children: [
                  Expanded(
                    child: Slider(
                      value: tempValue,
                      min: 0,
                      max: max,
                      divisions: ((max / step).round()),
                      label: tempValue.toInt().toString(),
                      activeColor: const Color(0xFF4CAF50),
                      onChanged: (val) {
                        setStateDialog(() {
                          tempValue = ((val / step).round() * step).toDouble();
                          if (tempValue > max) tempValue = max;
                          if (tempValue < 0) tempValue = 0;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      tempValue.toInt().toString(),
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
              onChanged(tempValue);
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


  Widget buildFilterButton(String title, VoidCallback onTap, {Key? key}) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFBFDAD9).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(title),
            const Spacer(),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }

  Widget buildToggleButton(String title, bool value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFBFDAD9).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(title),
            const Spacer(),
            if (value) const Icon(Icons.check, color: Color(0xFF4CAF50)),
          ],
        ),
      ),
    );
  }

  Widget buildSelectedChips(List<String> items, Function(String) onRemove) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Chip(
          label: Text(item),
          onDeleted: () => onRemove(item),
          deleteIcon: const Icon(Icons.close, size: 18),
          backgroundColor: const Color(0xFFBFDAD9),
          labelStyle: const TextStyle(color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white, // убрано для поддержки темы
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: Colors.white, // убрано для поддержки темы
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text("Фильтры", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildFilterButton("Регион", () {
              showOptionsPopup(allRegions, selectedRegions, (newList) {
                setState(() {
                  selectedRegions = newList;
                });
              }, regionKey);
            }, key: regionKey),
            buildSelectedChips(selectedRegions, (region) {
              setState(() {
                selectedRegions.remove(region);
              });
            }),

            buildFilterButton("Рейтинг", () {
              showSliderDialog("Рейтинг", minRating, 100, (value) {
                setState(() {
                  minRating = value;
                });
              });
            }),

            buildFilterButton("Бюджетных мест", () {
              showSliderDialog("Бюджетных мест", budgetPlaces, 1000, (value) {
                setState(() {
                  budgetPlaces = value;
                });
              }, step: 100);
            }),

            // Обновлённый стиль "Общежитие" и "Военный центр"
            buildToggleButton("Общежитие", hasDorm, () {
              setState(() {
                hasDorm = !hasDorm;
              });
            }),

            buildToggleButton("Военный уч. центр", hasMilitary, () {
              setState(() {
                hasMilitary = !hasMilitary;
              });
            }),

            buildFilterButton("Факультеты", () {
              showOptionsPopup(allFaculties, selectedFaculties, (newList) {
                setState(() {
                  selectedFaculties = newList;
                });
              }, facultiesKey);
            }, key: facultiesKey),
            buildSelectedChips(selectedFaculties, (faculty) {
              setState(() {
                selectedFaculties.remove(faculty);
              });
            }),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: clearFilters,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text("Очистить", style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: applyFilters,
                icon: const Icon(Icons.search),
                label: const Text("Поиск"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBFDAD9),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
