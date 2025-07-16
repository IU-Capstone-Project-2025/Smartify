import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:smartify/pages/universities/filter.dart';
import 'package:smartify/pages/universities/filter_page.dart';
import 'package:smartify/pages/universities/uniDetPAge.dart';
import 'package:smartify/pages/universities/universityCard.dart';
import 'package:smartify/pages/api_server/api_server.dart';
import 'favorite_uni_card.dart';
import 'package:smartify/l10n/app_localizations.dart';

class UniversityPage extends StatefulWidget {
  const UniversityPage({super.key});

  @override
  State<UniversityPage> createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage> {
  List universities = [];
  List filteredUniversities = [];
  List<Map> favoriteUniversities = [];
  UniversityFilter activeFilter = UniversityFilter();

  @override
  void initState() {
    super.initState();
    loadUniversityData();
  }

  Future<void> loadUniversityData() async {
    final List data = await UniversitiesMeneger.loadSavedJson();
    setState(() {
      universities = data;
      filteredUniversities = data;
    });
  }

  Future<void> refreshUniversityList() async {
    await UniversitiesMeneger.GetUniversititesJSON();
  }

  void filterSearch(String query) {
    final filtered = universities.where((uni) {
      final name = uni['название'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUniversities = filtered;
    });
  }

  void applyFilters(UniversityFilter filter) {
    final filtered = universities.where((uni) {
      if (filter.regions.isNotEmpty && !filter.regions.contains(uni['город'])) {
        return false;
      }
      double rating = double.tryParse(uni['рейтинг'].toString()) ?? 0.0;
      if (rating < filter.minRating) return false;
      if (filter.hasDorm && uni['общежитие'] != 'Да') return false;
      if (filter.hasMilitary && uni['воен. уч. центр'] != 'Да') return false;
      return true;
    }).toList();

    setState(() {
      activeFilter = filter;
      filteredUniversities = filtered;
    });
  }

  Future<void> openFilterPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UniversityFilterPage(currentFilter: activeFilter),
      ),
    );

    if (result is UniversityFilter) {
      applyFilters(result);
    }
  }

  void toggleFavorite(Map university) {
    setState(() {
      if (favoriteUniversities.any((u) => u['название'] == university['название'])) {
        favoriteUniversities.removeWhere((u) => u['название'] == university['название']);
      } else {
        favoriteUniversities.add(university);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white, // убрано для поддержки темы
      appBar: AppBar(
        // backgroundColor: Colors.white, // убрано для поддержки темы
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.universities, style: const TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.pets, color: Colors.white),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshUniversityList,
        child: universities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.searchUniversity,
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                            onChanged: filterSearch,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.teal[300],
                          child: IconButton(
                            icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                            onPressed: openFilterPage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (favoriteUniversities.isNotEmpty)
                  SliverToBoxAdapter(
                    child: FavoriteUniversitiesCarousel(
                      favorites: favoriteUniversities,
                      onTap: (uni) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UniversityDetailPage(
                              university: uni,
                              isFavorite: true,
                              onFavoriteToggle: toggleFavorite,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final uni = filteredUniversities[index];
                        final isFav = favoriteUniversities.any(
                            (favUni) => favUni['название'] == uni['название']);

                        return UniversityCard(
                          image: uni['фото'],
                          title: uni['название'],
                          rating: double.tryParse(uni['рейтинг'].toString()) ?? 4.0,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UniversityDetailPage(
                                  university: uni,
                                  isFavorite: isFav,
                                  onFavoriteToggle: toggleFavorite,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredUniversities.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class FavoriteUniversitiesCarousel extends StatefulWidget {
  final List<Map> favorites;
  final Function(Map) onTap;

  const FavoriteUniversitiesCarousel({
    required this.favorites,
    required this.onTap,
    super.key,
  });

  @override
  State<FavoriteUniversitiesCarousel> createState() =>
      _FavoriteUniversitiesCarouselState();
}

class _FavoriteUniversitiesCarouselState
    extends State<FavoriteUniversitiesCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            AppLocalizations.of(context)!.favorites,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = MediaQuery.of(context).size.width;
              double cardWidth = screenWidth * 0.7; // 70% ширины экрана
              return PageView.builder(
                controller: _pageController,
                itemCount: widget.favorites.length,
                itemBuilder: (context, index) {
                  final favUni = widget.favorites[index];
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = (_pageController.page! - index).abs();
                        value = (1 - (value * 0.3)).clamp(0.0, 1.0);
                      }
                      return Center(
                        child: Transform.scale(
                          scale: Curves.easeOut.transform(value),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: FavoriteUniversityCard(
                        university: favUni,
                        onTap: () => widget.onTap(favUni),
                        width: cardWidth,
                        height: 200,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.favorites.length, (index) {
              final isActive = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? Colors.teal : Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
