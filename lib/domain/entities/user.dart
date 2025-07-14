class User {
  final String id;
  final String email;
  final String? name;
  final String? role;

  User({required this.id, required this.email, this.name, this.role});

  factory User.fromFirebase(dynamic firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      name: firebaseUser.displayName ?? 'usuário',
      role: firebaseUser.role ?? 'admin',
    );
  }
}
