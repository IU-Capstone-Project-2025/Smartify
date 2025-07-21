class UniversityFilter {
  final List<String> regions;
  final double minRating;
  final double budgetPlaces;
  final bool hasDorm;
  final bool hasMilitary;
  final List<String> faculties;

  UniversityFilter({
    this.regions = const [],
    this.minRating = 0.0,
    this.budgetPlaces = 0.0,
    this.hasDorm = false,
    this.hasMilitary = false,
    this.faculties = const [],
  });
}
