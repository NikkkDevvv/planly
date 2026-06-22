abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String nim;

  RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.nim,
  });
}

class LogoutRequested extends AuthEvent {}
