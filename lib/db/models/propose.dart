class Propose {
  int id;
  int idTypeCuisine;
  int idRestaurant;

  Propose({
    required this.id,
    required this.idTypeCuisine,
    required this.idRestaurant,
  });

  factory Propose.fromMap(Map<String, dynamic> map) {
    return Propose(
      id: map['id'] as int,
      idTypeCuisine: map['idCuisine'] as int,
      idRestaurant: map['idResto'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCuisine': idTypeCuisine,
      'idResto': idRestaurant,
    };
  }
}
