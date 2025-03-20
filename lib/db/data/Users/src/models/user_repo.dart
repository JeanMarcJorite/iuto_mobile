import 'package:iuto_mobile/db/data/Users/src/entities/entities.dart';
import 'package:uuid/uuid.dart';


class MyUser {
  String id;
  String pseudo;
  String email;
  String nom;
  String prenom;
  String mdp;
  int idRole;
  DateTime date_creation;
  static final uuid = Uuid();

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
    id: MyUser.uuid.v4(),
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


  @override
  String toString() {
    return 'MyUser{id: $id, pseudo: $pseudo, email: $email, nom: $nom, prenom: $prenom, mdp: $mdp, idRole: $idRole, date_creation: $date_creation}';
  }
}
