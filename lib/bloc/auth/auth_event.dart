  import 'package:equatable/equatable.dart';

  /// Base class for all authentication events
  abstract class AuthEvent extends Equatable {
    const AuthEvent();

    @override
    List<Object> get props => [];
  }

  /// Event for login request
  class LoginRequested extends AuthEvent {
    final String email;
    final String password;

    const LoginRequested({
      required this.email,
      required this.password,
    });

    @override
    List<Object> get props => [email, password];
  }

  /// Event for register request
  class RegisterRequested extends AuthEvent {
    final String name;
    final String email;
    final String password;
    final String role;
    final String phone;
    final String birthDate;

    const RegisterRequested({
      required this.name,
      required this.email,
      required this.password,
      required this.role,
      required this.phone,
      required this.birthDate,
    });

    @override
    List<Object> get props => [name, email, password, role, phone, birthDate];

  }

  /// Event for logout request
  class LogoutRequested extends AuthEvent {
    const LogoutRequested();
  }

  /// Event to check authentication status on app start
  class AuthStatusChanged extends AuthEvent {
    const AuthStatusChanged();
  }
