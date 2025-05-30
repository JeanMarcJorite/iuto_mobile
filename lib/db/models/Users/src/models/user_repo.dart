import '../entities/entities.dart';

class MyUser {
  String id;
  String pseudo;
  String email;
  String nom;
  String prenom;
  String mdp;
  int idRole;
  DateTime date_creation;

  MyUser({
    required this.id,
    required this.pseudo,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.mdp,
    required this.idRole,
    required this.date_creation,
  });

  static final empty = MyUser(
    id: '',
    pseudo: '',
    email: '',
    nom: '',
    prenom: '',
    mdp: '',
    idRole: 2,
    date_creation: DateTime.now(),
  );

  MyUserEntity toEntity() {
    return MyUserEntity(
      id: id,
      pseudo: pseudo,
      email: email,
      nom: nom,
      prenom: prenom,
      mdp: mdp,
      idRole: idRole,
      date_creation: date_creation,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      id: entity.id,
      pseudo: entity.pseudo,
      email: entity.email,
      nom: entity.nom,
      prenom: entity.prenom,
      mdp: entity.mdp,
      idRole: entity.idRole,
      date_creation: entity.date_creation,
    );
  }

  @override
  String toString() {
    return 'MyUser{id: $id, pseudo: $pseudo, email: $email, nom: $nom, prenom: $prenom, mdp: $mdp, idRole: $idRole, date_creation: $date_creation}';
  }
}
