class CategoryAvg {
  final String name;
  final double avg;
  CategoryAvg({required this.name, required this.avg});
  factory CategoryAvg.fromJson(Map<String, dynamic> j)
    => CategoryAvg(name: j['name'], avg: (j['avg'] as num).toDouble());
  Map<String, dynamic> toJson() => {'name': name, 'avg': avg};
}
