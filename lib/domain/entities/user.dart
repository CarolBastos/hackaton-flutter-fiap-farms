class User {
  final String id;
  final String email;
  final String? name;

  User({required this.id, required this.email, this.name});

  factory User.fromFirebase(dynamic firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      name: firebaseUser.displayName,
    );
  }
}
