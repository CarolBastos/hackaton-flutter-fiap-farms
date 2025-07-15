class RegisterUserParams {
  final String name;
  final String email;
  final String password;
  final String role;

  RegisterUserParams({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}
