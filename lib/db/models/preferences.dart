class Preferences {
  final int id;
  final int idCuisine;
  final String idU;

  Preferences({
    required this.id,
    required this.idCuisine,
    required this.idU,
  });

  factory Preferences.fromMap(Map<String, dynamic> map) {
    return Preferences(
      id: map['id'] ?? 0,
      idCuisine: map['idCuisine'] ?? 0,
      idU: map['idU'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_cuisine': idCuisine,
      'idU': idU,
    };
  }
}
