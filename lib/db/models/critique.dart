class Critique {
  final String id; 
  final DateTime dateCritique; 
  final String idU; 
  final int idR; 
  final int note; 
  final String commentaire; 

  Critique({
    required this.id,
    required this.dateCritique,
    required this.idU,
    required this.idR,
    required this.note,
    required this.commentaire,
  });

  factory Critique.fromMap(Map<String, dynamic> map) {
    return Critique(
      id: map['id'] as String,
      dateCritique: DateTime.parse(map['date_critique'] as String),
      idU: map['idU'] as String,
      idR: map['idR'] as int,
      note: map['note'] as int,
      commentaire: map['commentaire'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_critique': dateCritique.toIso8601String(),
      'idU': idU,
      'idR': idR,
      'note': note,
      'commentaire': commentaire,
    };
  }
}