class TypeCuisine {
  int? id;
  String? name;

  TypeCuisine({this.id, this.name});

  factory TypeCuisine.fromMap(Map<String, dynamic> json) {
    return TypeCuisine(
      id: json['id_cuisine'] as int?,
      name: json['nom'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_cuisine': id,
      'nom': name,
    };
  }
}
