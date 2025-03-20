class MyUserEntity

{
  String id;
  String pseudo;
  String email;
  String nom;
  String prenom;
  String mdp;
  int idRole;
  DateTime date_creation;

  MyUserEntity({
    required this.id,
    required this.pseudo,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.mdp,
    required this.idRole,
    required this.date_creation,
    
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'pseudo': pseudo,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'mdp': mdp,
      'idRole': idRole,
      'date_creation': date_creation.toIso8601String(),
      
    };
  }

 static MyUserEntity fromDocument(Map<String, Object?> doc) {
  return MyUserEntity(
    id: doc['id'] as String,
    pseudo: doc['pseudo'] as String,
    email: doc['email'] as String,
    nom: doc['nom'] as String,
    prenom: doc['prenom'] as String,
    mdp: doc['mdp'] as String,
    idRole: doc['idRole'] as int,
    date_creation: DateTime.parse(doc['date_creation'] as String), 
  );
}

  @override
  String toString() {
    return 'MyUser{id: $id, pseudo: $pseudo, email: $email, nom: $nom, prenom: $prenom, mdp: $mdp, idRole: $idRole, date_creation: $date_creation}';
  }
}