class SplitGroup {
  final String id;
  String name;
  String desc;
  // Map of Body Part Name -> List of Exercise Names in that part
  Map<String, List<String>> parts;

  SplitGroup({
    required this.id,
    required this.name,
    this.desc = '',
    required this.parts,
  });

  List<String> get partNames => parts.keys.toList();

  List<String> getExercisesForPart(String part) => parts[part] ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'parts': parts.map((key, list) => MapEntry(key, list)),
    };
  }

  factory SplitGroup.fromMap(Map<String, dynamic> map) {
    final rawParts = map['parts'];
    Map<String, List<String>> parsedParts = {};

    if (rawParts is Map) {
      rawParts.forEach((key, val) {
        if (val is List) {
          parsedParts[key.toString()] = val.map((e) => e.toString()).toList();
        } else {
          parsedParts[key.toString()] = [];
        }
      });
    } else if (rawParts is List) {
      // Legacy format fallback: list of part names
      for (var p in rawParts) {
        parsedParts[p.toString()] = [];
      }
    }

    return SplitGroup(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      desc: map['desc'] as String? ?? '',
      parts: parsedParts,
    );
  }

  SplitGroup copyWith({
    String? id,
    String? name,
    String? desc,
    Map<String, List<String>>? parts,
  }) {
    return SplitGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      parts: parts ?? Map<String, List<String>>.from(this.parts),
    );
  }

  static List<SplitGroup> get defaultGroups => const [];
}
