import 'package:equatable/equatable.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Initial authentication state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when authentication is loading
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when authentication is successful
class AuthSuccess extends AuthState {
  final String message;
  final Map<String, dynamic> userData;
  final String? token;

  const AuthSuccess({
    required this.message,
    required this.userData,
    this.token,
  });

  @override
  List<Object> get props => [message, userData, token ?? ''];
}

/// State khusus ketika registrasi berhasil
class AuthRegisterSuccess extends AuthState {
  final String message;

  const AuthRegisterSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

/// State when authentication fails
class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object> get props => [error];
}

/// State when user is logged out
class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

/// State indicating user is authenticated
class AuthAuthenticated extends AuthState {
  final String email;

  const AuthAuthenticated({required this.email});

  @override
  List<Object> get props => [email];
}

/// State indicating user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
