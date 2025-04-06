  class Favoris {
    final int? id;
    final String idUtilisateur;
    final int idRestaurant;
    final DateTime dateAjout;

    Favoris({
      required this.id,
      required this.idUtilisateur,
      required this.idRestaurant,
      required this.dateAjout,
    });

    Map<String, dynamic> toMap() {
      return {
        if (id != null) 'id': id,
        'id_utilisateur': idUtilisateur,
        'id_restaurant': idRestaurant,
        'date_ajout': dateAjout.toIso8601String(),
      };
    }

    factory Favoris.fromMap(Map<String, dynamic> map) {
      return Favoris(
        id: map['id'],
        idUtilisateur: map['id_utilisateur'],
        idRestaurant: map['id_restaurant'],
        dateAjout: DateTime.parse(map['date_ajout']),
      );
    }
  }
