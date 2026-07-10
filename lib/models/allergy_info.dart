class AllergyInfo {
  final String title;
  final String emoji;
  final String description;
  final List<String> symptoms;
  final List<String> avoidFoods;
  final List<String> alternatives;

  const AllergyInfo({
    required this.title,
    required this.emoji,
    required this.description,
    required this.symptoms,
    required this.avoidFoods,
    required this.alternatives,
  });
}