class User {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final bool firstLogin;

  User({
    required this.id,
    required this.email,
    this.name,
    this.role,
    required this.firstLogin,
  });

  factory User.fromFirebase(dynamic firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      name: firebaseUser.displayName ?? 'usuário',
      role: firebaseUser.role ?? 'membro',
      firstLogin: firebaseUser.firstLogin ?? true,
    );
  }

  // Método copyWith implementado corretamente
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? firstLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      firstLogin: firstLogin ?? this.firstLogin,
    );
  }
}
